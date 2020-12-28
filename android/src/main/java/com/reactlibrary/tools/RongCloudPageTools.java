package com.reactlibrary.tools;

import android.app.Activity;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.facebook.react.ReactActivity;
import com.reactlibrary.R;

import io.rong.imkit.fragment.ConversationListFragment;
import io.rong.imlib.model.Conversation;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/13
 * @description
 */
public class RongCloudPageTools {

    private ConversationListFragment conversationListFragment;

    private RongCloudPageTools() {
    }

    private static class SingleHolder {
        private static RongCloudPageTools instance = new RongCloudPageTools();
    }

    public static RongCloudPageTools getInstance() {
        return SingleHolder.instance;
    }

    private FrameLayout realContainer;

    public void addFragmentContainer(final Activity activity) {
        GlobalTools.mainThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                if (realContainer != null) {
                    realContainer.removeAllViews();
                    realContainer = null;
                }
                final View imPlaceholder = findIMPlaceholder((ViewGroup) activity.findViewById(android.R.id.content));
                addFragmentContainer(activity, imPlaceholder);
            }
        });
    }

    public void addFragmentContainer(final Activity activity, final View imPlaceholder) {
        GlobalTools.mainThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                if (realContainer != null) {
                    realContainer.removeAllViews();
                    realContainer = null;
                }
                View content = activity.getWindow().getDecorView().findViewById(android.R.id.content);
                realContainer = new FrameLayout(content.getContext());
                realContainer.setId(R.id.fragmentcontainer);
                realContainer.setLayoutParams(new FrameLayout.LayoutParams(imPlaceholder.getWidth(),
                        imPlaceholder.getHeight()));
                ((FrameLayout) content).addView(realContainer);
                int[] locOnWindow = new int[2];
                imPlaceholder.getLocationInWindow(locOnWindow);
                realContainer.setX(locOnWindow[0]);
                realContainer.setY(locOnWindow[1]);
                showMessage(activity);
            }
        });
    }

    public void showHideContainer(final boolean isShow) {
        GlobalTools.mainThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                if (realContainer != null) {
                    realContainer.setVisibility(isShow ? View.VISIBLE : View.GONE);
                }
                if (conversationListFragment != null){
                    conversationListFragment.getView().setVisibility(isShow ? View.VISIBLE : View.GONE);
                }
            }
        });
    }

    public void showMessage(Activity activity) {
        View imPlaceholder = findIMPlaceholder((ViewGroup) activity.findViewById(android.R.id.content));
        if (imPlaceholder == null) return;
        final String packageName = activity.getApplicationInfo().packageName;
        conversationListFragment = new ConversationListFragment();
        Uri uri = Uri.parse("rong://" + packageName).buildUpon()
                .appendPath("conversationlist")
                .appendQueryParameter(Conversation.ConversationType.PRIVATE.getName(), "false") //设置私聊会话是否聚合显示
                .appendQueryParameter(Conversation.ConversationType.GROUP.getName(), "false")//群组
                .appendQueryParameter(Conversation.ConversationType.PUBLIC_SERVICE.getName(), "false")//公共服务号
                .appendQueryParameter(Conversation.ConversationType.APP_PUBLIC_SERVICE.getName(), "false")//订阅号
                .appendQueryParameter(Conversation.ConversationType.SYSTEM.getName(), "true")//系统
                .build();
        conversationListFragment.setUri(uri);
        FragmentManager manager = ((ReactActivity) activity).getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        transaction.replace(R.id.fragmentcontainer, conversationListFragment);
        transaction.commit();
    }

    private View findIMPlaceholder(ViewGroup parent) {
        for (int i = 0; i < parent.getChildCount(); i++) {
            View view = parent.getChildAt(i);
            if (String.valueOf(R.id.fragmentcontainer).equals(String.valueOf(view.getTag()))) {
                return view;
            }
            if (view instanceof ViewGroup) {
                View result = findIMPlaceholder((ViewGroup) view);
                if (result != null) {
                    return result;
                }
            }
        }
        return null;
    }
}
