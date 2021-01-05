package com.reactlibrary.tools;

public class HttpData<T>  {

    private int code;

    private String message;

    private T data;

    private int status;

    private Object ver;

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public Object getVer() {
        return ver;
    }

    public void setVer(Object ver) {
        this.ver = ver;
    }
}
