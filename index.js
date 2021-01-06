import { requireNativeComponent } from 'react-native';
import {
    NativeModules,
    Platform
} from "react-native";

const RongcloudManager = requireNativeComponent(Platform.OS == 'ios' ? 'ConversationList' : 'RongcloudManager', null);

export default RongcloudManager;

export const initIMSDK = (appId) => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.initIMSDK && NativeModules.RongcloudModule.initIMSDK(appId);
}

export const showHideContainer = (isShow) => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.showHideContainer && NativeModules.RongcloudModule.showHideContainer(isShow);
}

export const connectIM = (token) => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.connectIM && NativeModules.RongcloudModule.connectIM(token);
}

export const disconnectIM = () => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.disconnectIM && NativeModules.RongcloudModule.disconnectIM();
}

export const logoutIM = () => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.logoutIM && NativeModules.RongcloudModule.logoutIM();
}

export const startConversation = (targetId, targetName) => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.startConversation && NativeModules.RongcloudModule.startConversation(targetId, targetName);
}

export const isPreLoginResultValid = () => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.isPreLoginResultValid && NativeModules.RongcloudModule.isPreLoginResultValid();
}

export const eAccountLogin = () => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.eAccountLogin && NativeModules.RongcloudModule.eAccountLogin();
}

export const preGetToken = () => {
    if ( !NativeModules.RongcloudModule || !NativeModules.RongcloudModule.preGetToken ) return console.log('preGetToken not defined');
    return NativeModules.RongcloudModule.preGetToken();
}

export const setUserInfo = (userInfo) => {
    return NativeModules.RongcloudModule && NativeModules.RongcloudModule.setUserInfo && NativeModules.RongcloudModule.setUserInfo(userInfo);
}
