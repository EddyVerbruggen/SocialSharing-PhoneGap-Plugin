package nl.xservices.plugins;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.PluginResult;
import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.*;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class SocialSharing extends CordovaPlugin {

  private static final String ACTION_AVAILABLE_EVENT = "available";
  private static final String ACTION_SHARE_EVENT = "share";
  private static final String ACTION_CAN_SHARE_VIA = "canShareVia";
  private static final String ACTION_SHARE_VIA_WHATSAPP_EVENT = "shareViaWhatsApp";

  private CallbackContext callbackContext;

  File downloadedFile;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext pCallbackContext) throws JSONException {
    this.callbackContext = pCallbackContext;
    try {
      if (ACTION_AVAILABLE_EVENT.equals(action)) {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        return true;
      } else if (ACTION_SHARE_EVENT.equals(action)) {
        final String message = args.getString(0);
        final String subject = args.getString(1);
        final String image = args.getString(2);
        final String url = args.getString(3);
        doSendIntent(subject, message, image, url, null, false);
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        return true;
      } else if (ACTION_SHARE_VIA_WHATSAPP_EVENT.equals(action)) {
        doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "whatsapp", false);
        return true;
      } else if (ACTION_CAN_SHARE_VIA.equals(action)) {
        doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), args.getString(4), true);
        return true;
      } else {
        callbackContext.error("socialSharing." + action + " is not a supported function. Did you mean '" + ACTION_SHARE_EVENT + "'?");
        return false;
      }
    } catch (Exception e) {
      callbackContext.error(e.getMessage());
      return false;
    }
  }

  private void doSendIntent(String subject, String message, String image, String url, final String appPackageName, final boolean peek) throws IOException {
    final CordovaInterface mycordova = cordova;
    final CordovaPlugin plugin = this;
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
          downloadFromUrl(new URL(image).openConnection().getInputStream(), dir, filename);
        } else {
          downloadFromUrl(webView.getContext().getAssets().open(image), dir, filename);
        }
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
      if (activity != null) {
        if (peek) {
          callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        } else {
          sendIntent.addCategory(Intent.CATEGORY_LAUNCHER);
          sendIntent.setComponent(new ComponentName(activity.applicationInfo.packageName, activity.name));
          mycordova.startActivityForResult(plugin, sendIntent, 0);
        }
      }
    } else {
      if (peek) {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
      } else {
        mycordova.startActivityForResult(plugin, Intent.createChooser(sendIntent, null), 1);
      }
    }
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
    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, getShareActivities(activityList)));
    return null;
  }

  private JSONArray getShareActivities(List<ResolveInfo> activityList) {
    List<String> packages = new ArrayList<String>();
    for (final ResolveInfo app : activityList) {
      packages.add(app.activityInfo.packageName);
    }
    return new JSONArray(packages);
  }

  // cleanup after ourselves
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    if (downloadedFile != null) {
      downloadedFile.delete();
    }
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

  private void downloadFromUrl(InputStream is, String dirName, String fileName) throws IOException {
    final File dir = new File(dirName);
    downloadedFile = new File(dir, fileName);
    BufferedInputStream bis = new BufferedInputStream(is);
    ByteArrayBuffer baf = new ByteArrayBuffer(5000);
    int current;
    while ((current = bis.read()) != -1) {
      baf.append((byte) current);
    }
    FileOutputStream fos = new FileOutputStream(downloadedFile);
    fos.write(baf.toByteArray());
    fos.flush();
    fos.close();
  }
}