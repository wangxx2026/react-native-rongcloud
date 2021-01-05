package com.reactlibrary.server;

import com.reactlibrary.bean.IMUserInfo;
import com.reactlibrary.tools.HttpData;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

public interface UserInfoAPI {
    @GET("user/{id}")
    Call<HttpData<IMUserInfo>> getUserInfo(@Path("id") String id);
}