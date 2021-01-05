package com.reactlibrary.tools;

import android.os.Handler;
import android.os.Looper;

import com.reactlibrary.server.UserInfoAPI;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/13
 * @description
 */
public class GlobalTools {
    public static Handler mainThreadHandler = new Handler(Looper.getMainLooper());

    public static UserInfoAPI getUserInfoService(){
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("http://101.133.164.241:8081/v1/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        UserInfoAPI service = retrofit.create(UserInfoAPI.class);
        return service;
    }
}



