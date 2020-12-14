package com.reactlibrary.bean;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/12
 * @description
 */
public class IMUserInfo {
    public IMUserInfo() {
    }

    public IMUserInfo(String nickName, String avatar) {
        this.nickName = nickName;
        this.avatar = avatar;
    }

    public String nickName = "";
    public String avatar = "";
}
