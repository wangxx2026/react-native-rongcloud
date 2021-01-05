package com.reactlibrary.view;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;

import com.reactlibrary.R;
import com.reactlibrary.tools.CheckPermissionUtils;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import io.rong.eventbus.EventBus;
import io.rong.imkit.RongContext;
import io.rong.imkit.RongIM;
import io.rong.imkit.RongKitIntent;
import io.rong.imkit.fragment.ConversationFragment;
import io.rong.imlib.model.Conversation;

/**
 * 会话页面
 */
public class ConversationActivity extends TitleBaseActivity {

    private String TAG = ConversationActivity.class.getSimpleName();
    private ConversationFragment fragment;
    private String title;
    private boolean isExtensionHeightInit = false;
    private boolean isSoftKeyOpened = false;
    private boolean isClickToggle = false;
    private boolean isExtensionExpanded;
    private int extensionExpandedHeight;
    private int extensionCollapsedHeight;
    private static List<String> rencentShowIdList = new ArrayList<>();
    private final int REQUEST_CODE_PERMISSION = 118;
    private String[] permissions = {Manifest.permission.READ_EXTERNAL_STORAGE};
    /**
     * 对方id
     */
    private String targetId;
    /**
     * 会话类型
     */
    private Conversation.ConversationType conversationType;

    /**
     * 在会话类型为群组时：是否为群主
     */
    private boolean isGroupOwner;
    /**
     * 在会话类型为群组时：是否为群管理员
     */
    private boolean isGroupManager;

    private DelayDismissHandler mHandler;
    private final int RECENTLY_POPU_DISMISS = 0x2870;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_conversation);
        // 没有intent 的则直接返回
        Intent intent = getIntent();
        if (intent == null || intent.getData() == null) {
            finish();
            return;
        }

        targetId = intent.getData().getQueryParameter("targetId");
        conversationType = Conversation.ConversationType.valueOf(intent.getData()
                .getLastPathSegment().toUpperCase(Locale.US));
        title = intent.getData().getQueryParameter("title");
        mHandler = new DelayDismissHandler(this);
        initView();
//        EventBus.getDefault().register(this);
//        initScreenShotListener();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mHandler.removeCallbacksAndMessages(null);
        EventBus.getDefault().unregister(this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    private void initView() {
        initTitleBar(conversationType, targetId);
        initConversationFragment();
    }

    private void initConversationFragment() {
        /**
         * 加载会话界面 。 ConversationFragmentEx 继承自 ConversationFragment
         */
        FragmentManager fragmentManager = getSupportFragmentManager();
        Fragment existFragment = fragmentManager.findFragmentByTag(ConversationFragment.class.getCanonicalName());
        if (existFragment != null) {
            fragment = (ConversationFragment) existFragment;
            FragmentTransaction transaction = fragmentManager.beginTransaction();
            transaction.show(fragment);
            transaction.commitAllowingStateLoss();
        } else {
            fragment = new ConversationFragment();


            if (conversationType.equals(Conversation.ConversationType.PRIVATE)
                    || conversationType.equals(Conversation.ConversationType.GROUP)) {
            }

            FragmentTransaction transaction = fragmentManager.beginTransaction();
            transaction.add(R.id.container, fragment, ConversationFragment.class.getCanonicalName());
            transaction.commitAllowingStateLoss();
        }

    }

    private static class DelayDismissHandler extends Handler {
        //持有弱引用MainActivity,GC回收时会被回收掉.
        private WeakReference<ConversationActivity> mActivity;

        public DelayDismissHandler(ConversationActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
        }
    }

    /**
     * 初始化 title
     *
     * @param conversationType
     * @param targetId
     */
    private void initTitleBar(Conversation.ConversationType conversationType, String targetId) {
        // title 布局设置
        // 左边返回按钮
        getTitleBar().setOnBtnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (fragment != null && !fragment.onBackPressed()) {
                    if (fragment.isLocationSharing()) {
                        fragment.showQuitLocationSharingDialog(ConversationActivity.this);
                        return;
                    }
                    hintKbTwo();
                }
                finish();
            }
        });

        getTitleBar().setTitle(title);
        getTitleBar().getBtnRight().setVisibility(View.GONE);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (KeyEvent.KEYCODE_BACK == event.getKeyCode()) {
            if (fragment != null && !fragment.onBackPressed()) {
                if (fragment.isLocationSharing()) {
                    fragment.showQuitLocationSharingDialog(this);
                    return true;
                }
                finish();
            }
        }
        return false;
    }

    private void hintKbTwo() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm.isActive() && getCurrentFocus() != null) {
            if (getCurrentFocus().getWindowToken() != null) {
                imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
            }
        }
    }

    @Override
    public void clearAllFragmentExistBeforeCreate() {
    }

    @Override
    public void onRequestPermissionsResult(final int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CODE_PERMISSION && !CheckPermissionUtils.allPermissionGranted(grantResults)) {
            List<String> permissionsNotGranted = new ArrayList<>();
            for (String permission : permissions) {
                if (!ActivityCompat.shouldShowRequestPermissionRationale(this, permission)) {
                    permissionsNotGranted.add(permission);
                }
            }
            if (permissionsNotGranted.size() > 0) {
                DialogInterface.OnClickListener listener = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        switch (which) {
                            case DialogInterface.BUTTON_POSITIVE:
                                Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                Uri uri = Uri.fromParts("package", getPackageName(), null);
                                intent.setData(uri);
                                startActivityForResult(intent, requestCode);
                                break;
                            case DialogInterface.BUTTON_NEGATIVE:
                                break;
                            default:
                                break;
                        }
                    }
                };
                CheckPermissionUtils.showPermissionAlert(this, getResources().getString(R.string.seal_grant_permissions) + CheckPermissionUtils.getNotGrantedPermissionMsg(this, permissionsNotGranted), listener);
            }
        }
    }

    /**
     * 在当前会话时是否为群主
     *
     * @return
     */
    public boolean isGroupOwner() {
        return isGroupOwner;
    }

    /**
     * 在当前会话时是否为群管理员
     *
     * @return
     */
    public boolean isGroupManager() {
        return isGroupManager;
    }

}
