package com.reactlibrary;

import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.google.gson.Gson;
import com.reactlibrary.bean.IMUserInfo;
import com.reactlibrary.tools.RongCloudPageTools;
import com.reactlibrary.tools.RongCloudTools;

import io.rong.imkit.RongIM;
import io.rong.imkit.fragment.ConversationListFragment;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.UserInfo;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/12
 * @description
 */
public class RongcloudModule extends ReactContextBaseJavaModule {

    public RongcloudModule(@Nullable ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "RongcloudModule";
    }

    @ReactMethod
    public void initIMSDK(String appKey){
        RongIM.init(getReactApplicationContext(), appKey);
    }

    @ReactMethod
    public void connectIM(String token, Promise promise) {
        RongCloudTools.connectIM(getCurrentActivity(), token, promise);
    }

    @ReactMethod
    public void disconnectIM(){
        RongIM.getInstance().disconnect();
    }

    @ReactMethod
    public void logoutIM(){
        RongIM.getInstance().logout();
    }

    @ReactMethod
    public void startConversation(String targetId, String targetName) {
        RongCloudTools.startConversation(getCurrentActivity(), targetId, targetName);
    }

    @ReactMethod
    public void setUserInfo(ReadableMap userInfoJson) {
        RongCloudTools.setUserInfo(userInfoJson);
    }

    @ReactMethod
    public void showHideContainer(final boolean isShow) {
        RongCloudPageTools.getInstance().showHideContainer(isShow);
    }

    @ReactMethod
    public void exitIM(boolean isReceiveMsgAfterExit) {
        if (isReceiveMsgAfterExit) {
            RongCloudTools.disconnect();
        } else {
            RongCloudTools.logout();
        }
    }
}
