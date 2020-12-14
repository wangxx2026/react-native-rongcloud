package com.reactlibrary.tools;

import android.os.Handler;
import android.os.Looper;

/**
 * @author Army
 * @version V_1.0.0
 * @date 2020/12/13
 * @description
 */
public class GlobalTools {
    public static Handler mainThreadHandler = new Handler(Looper.getMainLooper());
}
