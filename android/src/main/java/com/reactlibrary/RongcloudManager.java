package com.reactlibrary;

import android.app.Fragment;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.reactlibrary.tools.RongCloudPageTools;

import java.util.Timer;
import java.util.TimerTask;

import io.rong.imkit.fragment.ConversationListFragment;
import io.rong.imlib.model.Conversation;

public class RongcloudManager extends SimpleViewManager<View> {

    public static final String REACT_CLASS = "RongcloudManager";
    private ThemedReactContext mContext;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public View createViewInstance(ThemedReactContext context) {
        View placeholder = new View(context);
        mContext = context;
        placeholder.setTag(R.id.fragmentcontainer);
        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        placeholder.setLayoutParams(params);
        RongCloudPageTools.getInstance().addFragmentContainer(mContext.getCurrentActivity());
        return placeholder;
    }
}
