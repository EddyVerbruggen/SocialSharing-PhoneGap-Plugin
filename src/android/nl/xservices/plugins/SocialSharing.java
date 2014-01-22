package nl.xservices.plugins;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Base64;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.*;
import java.net.URL;
import java.util.List;

public class SocialSharing extends CordovaPlugin {

  private static final String ACTION_AVAILABLE_EVENT = "available";
  private static final String ACTION_SHARE_EVENT = "share";
  private static final String ACTION_SHARE_VIA = "shareVia"; // maybe for a future version?
  private static final String ACTION_SHARE_VIA_TWITTER_EVENT = "shareViaTwitter";
  private static final String ACTION_SHARE_VIA_FACEBOOK_EVENT = "shareViaFacebook";
  // TODO this one has not been tested yet on Android
  private static final String ACTION_SHARE_VIA_WHATSAPP_EVENT = "shareViaWhatsApp";

  private File tempFile;
  private CallbackContext callbackContext;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext pCallbackContext) throws JSONException {
    this.callbackContext = pCallbackContext;
    try {
      if (ACTION_AVAILABLE_EVENT.equals(action)) {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        return true;
      } else if (ACTION_SHARE_EVENT.equals(action)) {
        return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), null);
      } else if (ACTION_SHARE_VIA_TWITTER_EVENT.equals(action)) {
        return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "twitter");
      } else if (ACTION_SHARE_VIA_FACEBOOK_EVENT.equals(action)) {
        return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "facebook");
      } else if (ACTION_SHARE_VIA_WHATSAPP_EVENT.equals(action)) {
        return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "whatsapp");
      } else if (ACTION_SHARE_VIA.equals(action)) {
        return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), args.getString(4));
      } else {
        callbackContext.error("socialSharing." + action + " is not a supported function. Did you mean '" + ACTION_SHARE_EVENT + "'?");
        return false;
      }
    } catch (Exception e) {
      callbackContext.error(e.getMessage());
      return false;
    }
  }

  private boolean doSendIntent(String message, String subject, String image, String url, String appPackageName) throws IOException {
    final Intent sendIntent = new Intent(android.content.Intent.ACTION_SEND);
    final String dir = webView.getContext().getExternalFilesDir(null) + "/socialsharing-downloads";
    createDir(dir);
    sendIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);

    String localImage = image;
    if ("".equals(image) || "null".equalsIgnoreCase(image)) {
      sendIntent.setType("text/plain");
    } else {
      sendIntent.setType("image/*");
      if (image.startsWith("http") || image.startsWith("www/")) {
        final String filename = getFileName(image);
        localImage = "file://" + dir + "/" + filename;
        if (image.startsWith("http")) {
          saveFile(getBytes(new URL(image).openConnection().getInputStream()), dir, filename);
        } else {
          saveFile(getBytes(webView.getContext().getAssets().open(image)), dir, filename);
        }
      } else if (image.startsWith("data:")) {
        // image looks like this: data:image/png;base64,R0lGODlhDAA...
        final String encodedImg = image.substring(image.indexOf(";base64,") + 8);
        // the filename needs a valid extension, so it renders correctly in target apps
        final String imgExtension = image.substring(image.indexOf("image/") + 6, image.indexOf(";base64"));
        final String fileName = "image." + imgExtension;
        saveFile(Base64.decode(encodedImg, Base64.DEFAULT), dir, fileName);
        localImage = "file://" + dir + "/" + fileName;
      } else if (!image.startsWith("file://")) {
        throw new IllegalArgumentException("URL_NOT_SUPPORTED");
      }
      sendIntent.putExtra(android.content.Intent.EXTRA_STREAM, Uri.parse(localImage));
    }
    if (!"".equals(subject) && !"null".equalsIgnoreCase(subject)) {
      sendIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
    }
    // add the URL to the message, as there seems to be no separate field
    if (!"".equals(url) && !"null".equalsIgnoreCase(url)) {
      if (!"".equals(message) && !"null".equalsIgnoreCase(message)) {
        message += " " + url;
      } else {
        message = url;
      }
    }
    if (!"".equals(message) && !"null".equalsIgnoreCase(message)) {
      sendIntent.putExtra(android.content.Intent.EXTRA_TEXT, message);
    }

    if (appPackageName != null) {
      final ActivityInfo activity = getActivity(sendIntent, appPackageName);
      if (activity == null) {
        return false;
      }
      sendIntent.addCategory(Intent.CATEGORY_LAUNCHER);
      sendIntent.setComponent(new ComponentName(activity.applicationInfo.packageName, activity.name));
      this.cordova.startActivityForResult(this, sendIntent, 0);
    } else {
      this.cordova.startActivityForResult(this, Intent.createChooser(sendIntent, null), 1);
    }
    return true;
  }

  private ActivityInfo getActivity(final Intent shareIntent, final String appPackageName) {
    final PackageManager pm = webView.getContext().getPackageManager();
    List<ResolveInfo> activityList = pm.queryIntentActivities(shareIntent, 0);
    for (final ResolveInfo app : activityList) {
      if ((app.activityInfo.packageName).contains(appPackageName)) {
        return app.activityInfo;
      }
    }
    // no matching app found
    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "not available, this is: " + activityList));
    return null;
  }

  // cleanup after ourselves
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    if (tempFile != null) {
      //noinspection ResultOfMethodCallIgnored
      tempFile.delete();
    }
    // note that the resultCode needs to be sent correctly by the sharing app, which is not always the case :(
    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, resultCode == Activity.RESULT_OK));
  }

  private void createDir(final String downloadDir) throws IOException {
    final File dir = new File(downloadDir);
    if (!dir.exists()) {
      if (!dir.mkdirs()) {
        throw new IOException("CREATE_DIRS_FAILED");
      }
    }
  }

  private String getFileName(String url) {
    final int lastIndexOfSlash = url.lastIndexOf('/');
    if (lastIndexOfSlash == -1) {
      return url;
    } else {
      return url.substring(lastIndexOfSlash + 1);
    }
  }

  private byte[] getBytes(InputStream is) throws IOException {
    BufferedInputStream bis = new BufferedInputStream(is);
    ByteArrayBuffer baf = new ByteArrayBuffer(5000);
    int current;
    while ((current = bis.read()) != -1) {
      baf.append((byte) current);
    }
    return baf.toByteArray();
  }

  private void saveFile(byte[] bytes, String dirName, String fileName) throws IOException {
    final File dir = new File(dirName);
    tempFile = new File(dir, fileName);
    FileOutputStream fos = new FileOutputStream(tempFile);
    fos.write(bytes);
    fos.flush();
    fos.close();
  }
}