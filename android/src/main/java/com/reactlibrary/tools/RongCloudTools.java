package com.reactlibrary.tools;

import android.app.Activity;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.lifecycle.LiveData;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.google.gson.Gson;
import com.reactlibrary.R;
import com.reactlibrary.bean.IMUserInfo;

import java.util.HashMap;

import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.UserInfo;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.reactlibrary.tools.GlobalTools.getUserInfoService;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/13
 * @description
 */
public class RongCloudTools {
    
    public static final String TAG = RongCloudTools.class.getSimpleName();

    /**
     * 在断开和融云的连接后，有新消息时，仍然能够收到推送通知
     */
    public static void disconnect() {
        RongIM.getInstance().disconnect();
    }

    /**
     * 不会收到任何推送通知并断开连接，退出登录也需调用 logout() 方法
     */
    public static void logout() {
        RongIM.getInstance().logout();
    }

    public static void connectIM(final Activity activity, String token, final Promise promise) {
        // 防止有连接没断开
        disconnect();
        RongIM.connect(token, new RongIMClient.ConnectCallback() {
            @Override
            public void onDatabaseOpened(RongIMClient.DatabaseOpenStatus code) {
                //消息数据库打开，可以进入到主页面
                Log.i(TAG, "onDatabaseOpened: " + code.name());
            }

            @Override
            public void onSuccess(String s) {
                //连接成功
                Log.i(TAG, "onSuccess: " + s);
                //RongCloudPageTools.getInstance().showMessage(activity);
                WritableMap map = Arguments.createMap();
                map.putString("msg", s);
                if (promise != null){
                    promise.resolve(map);
                }
            }

            @Override
            public void onError(RongIMClient.ConnectionErrorCode errorCode) {
                Log.i(TAG, "onError: " + errorCode.name());
                if(errorCode.equals(RongIMClient.ConnectionErrorCode.RC_CONN_TOKEN_INCORRECT)) {
                    //从 APP 服务获取新 token，并重连
                } else {
                    //无法连接 IM 服务器，请根据相应的错误码作出对应处理
                    if (promise != null){
                        promise.reject(String.valueOf(errorCode.getValue()), errorCode.name());
                    }
                }
            }
        });
    }

    public static void setUserInfo(ReadableMap userInfoMap) {
        HashMap user = userInfoMap.toHashMap();

        IMUserInfo imUserInfo = new IMUserInfo((String) user.get("nickname"), (String) user.get("avatar"));
        RongIM.setUserInfoProvider(new RongIM.UserInfoProvider() {
            @Override
            public UserInfo getUserInfo(String userId) {
                updateUserInfo(userId);
                return null;
            }

        }, true);
        UserInfo userInfo = new UserInfo(RongIM.getInstance().getCurrentUserId(), imUserInfo.nickname,
                Uri.parse(imUserInfo.avatar));
        RongIM.getInstance().refreshUserInfoCache(userInfo);
    }

    /**
     * 更新用户信息
     *
     * @param userId
     */
    public static void updateUserInfo(final String userId) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                getUserInfoService().getUserInfo(userId).enqueue(new Callback<HttpData<IMUserInfo>>(){

                    @Override
                    public void onResponse(Call<HttpData<IMUserInfo>> call, Response<HttpData<IMUserInfo>> response) {
                        HttpData<IMUserInfo> data = response.body();
                        if (data != null && data.getStatus() == 0){
                            IMUserInfo imUserInfo = data.getData();
                            UserInfo userInfo = new UserInfo(userId, imUserInfo.nickname,
                                    Uri.parse(imUserInfo.avatar));
                            RongIM.getInstance().refreshUserInfoCache(userInfo);
                        }

                    }

                    @Override
                    public void onFailure(Call<HttpData<IMUserInfo>> call, Throwable t) {

                    }
                });
            }
        };
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(runnable);
    }

    public static void startConversation(Activity activity, String targetId, String targetName) {
        Conversation.ConversationType conversationType  = Conversation.ConversationType.PRIVATE;
        RongIM.getInstance().startConversation(activity , conversationType, targetId, targetName, null);
    }
}
