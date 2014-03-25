package nl.xservices.plugins;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.util.Base64;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SocialSharing extends CordovaPlugin {

  private static final String ACTION_AVAILABLE_EVENT = "available";
  private static final String ACTION_SHARE_EVENT = "share";
  private static final String ACTION_CAN_SHARE_VIA = "canShareVia";
  private static final String ACTION_SHARE_VIA = "shareVia";
  private static final String ACTION_SHARE_VIA_TWITTER_EVENT = "shareViaTwitter";
  private static final String ACTION_SHARE_VIA_FACEBOOK_EVENT = "shareViaFacebook";
  private static final String ACTION_SHARE_VIA_WHATSAPP_EVENT = "shareViaWhatsApp";
  private static final String ACTION_SHARE_VIA_SMS_EVENT = "shareViaSMS";

  private CallbackContext callbackContext;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext pCallbackContext) throws JSONException {
    this.callbackContext = pCallbackContext;
    if (ACTION_AVAILABLE_EVENT.equals(action)) {
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
      return true;
    } else if (ACTION_SHARE_EVENT.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), null, false);
    } else if (ACTION_SHARE_VIA_TWITTER_EVENT.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "twitter", false);
    } else if (ACTION_SHARE_VIA_FACEBOOK_EVENT.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "com.facebook.katana", false);
    } else if (ACTION_SHARE_VIA_WHATSAPP_EVENT.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), "whatsapp", false);
    } else if (ACTION_CAN_SHARE_VIA.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), args.getString(4), true);
    } else if (ACTION_SHARE_VIA.equals(action)) {
      return doSendIntent(args.getString(0), args.getString(1), args.getString(2), args.getString(3), args.getString(4), false);
    } else if (ACTION_SHARE_VIA_SMS_EVENT.equals(action)) {
      return invokeSMSIntent(args.getString(0), args.getString(1));
    } else {
      callbackContext.error("socialSharing." + action + " is not a supported function. Did you mean '" + ACTION_SHARE_EVENT + "'?");
      return false;
    }
  }

  private boolean doSendIntent(final String msg, final String subject, final String image, final String url, final String appPackageName, final boolean peek) {

    final CordovaInterface mycordova = cordova;
    final CordovaPlugin plugin = this;

    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        String message = msg;
        try {
          final Intent sendIntent = new Intent(android.content.Intent.ACTION_SEND);
          final String dir = webView.getContext().getExternalFilesDir(null) + "/socialsharing-downloads";
          createDir(dir);
          sendIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);

          String localImage = image;
          if ("".equals(image) || "null".equalsIgnoreCase(image)) {
            sendIntent.setType("text/plain");
          } else {
            // we're assuming an image, but this can be any filetype you like
            sendIntent.setType("image/*");
            if (image.startsWith("http") || image.startsWith("www/")) {
              String filename = getFileName(image);
              localImage = "file://" + dir + "/" + filename;
              if (image.startsWith("http")) {
                // filename optimisation taken from https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/pull/56
                URLConnection connection = new URL(image).openConnection();
                String disposition = connection.getHeaderField("Content-Disposition");
                if (disposition != null) {
                  final Pattern dispositionPattern = Pattern.compile("filename=([^;]+)");
                  Matcher matcher = dispositionPattern.matcher(disposition);
                  if (matcher.find()) {
                    filename = matcher.group(1).replaceAll("[^a-zA-Z0-9._-]", "");
                    localImage = "file://" + dir + "/" + filename;
                  }
                }
                saveFile(getBytes(connection.getInputStream()), dir, filename);
              } else {
                saveFile(getBytes(webView.getContext().getAssets().open(image)), dir, filename);
              }
            } else if (image.startsWith("data:")) {
              // image looks like this: data:image/png;base64,R0lGODlhDAA...
              final String encodedImg = image.substring(image.indexOf(";base64,") + 8);
              // correct the intent type if anything else was passed, like a pdf: data:application/pdf;base64,..
              if (!image.contains("data:image/")) {
                sendIntent.setType(image.substring(image.indexOf("data:") + 5, image.indexOf(";base64")));
              }
              // the filename needs a valid extension, so it renders correctly in target apps
              final String imgExtension = image.substring(image.indexOf("/") + 1, image.indexOf(";base64"));
              final String fileName = "file." + imgExtension;
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
        } catch (IOException e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
    return true;
  }

  public boolean invokeSMSIntent(String message, String p_phonenumbers) {
    Intent intent;
    final String phonenumbers = getPhoneNumbersWithManufacturerSpecificSeparators(p_phonenumbers);
    if (Build.VERSION.SDK_INT >= 19) { // Build.VERSION_CODES.KITKAT) {
      // passing in no phonenumbers for kitkat may result in an error,
      // but it may also work for some devices, so documentation will need to cover this case
      intent = new Intent(Intent.ACTION_SENDTO);
      intent.setData(Uri.parse("smsto:" + (phonenumbers == null ? "" : phonenumbers)));
    } else {
      intent = new Intent(Intent.ACTION_VIEW);
      intent.setType("vnd.android-dir/mms-sms");
      if (phonenumbers != null) {
        intent.putExtra("address", phonenumbers);
      }
    }
    intent.putExtra("sms_body", message);
    try {
      this.cordova.startActivityForResult(this, intent, 0);
      return true;
    } catch (ActivityNotFoundException ignore) {
      return false;
    }
  }

  private static String getPhoneNumbersWithManufacturerSpecificSeparators(String phonenumbers) {
    if (!"".equals(phonenumbers) && !"null".equalsIgnoreCase(phonenumbers)) {
      char separator;
      if (android.os.Build.MANUFACTURER.equalsIgnoreCase("samsung")) {
        separator = ',';
      } else {
        separator = ';';
      }
      return phonenumbers.replace(';', separator).replace(',', separator);
    }
    return null;
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

  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
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
    cleanupOldFiles(dir);
    final FileOutputStream fos = new FileOutputStream(new File(dir, fileName));
    fos.write(bytes);
    fos.flush();
    fos.close();
  }

  /**
   * As file.deleteOnExit does not work on Android, we need to delete files manually.
   * Deleting them in onActivityResult is not a good idea, because for example a base64 encoded file
   * will not be available for upload to Facebook (it's deleted before it's uploaded).
   * So the best approach is deleting old files when saving (sharing) a new one.
   */
  private void cleanupOldFiles(File dir) {
    for (File f : dir.listFiles()) {
      //noinspection ResultOfMethodCallIgnored
      f.delete();
    }
  }
}
