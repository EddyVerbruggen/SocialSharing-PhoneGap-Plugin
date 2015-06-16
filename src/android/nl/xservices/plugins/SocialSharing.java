package nl.xservices.plugins;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.*;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.text.Html;
import android.util.Base64;
import android.view.Gravity;
import android.widget.Toast;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SocialSharing extends CordovaPlugin {

  private static final String ACTION_AVAILABLE_EVENT = "available";
  private static final String ACTION_SHARE_EVENT = "share";
  private static final String ACTION_CAN_SHARE_VIA = "canShareVia";
  private static final String ACTION_CAN_SHARE_VIA_EMAIL = "canShareViaEmail";
  private static final String ACTION_SHARE_VIA = "shareVia";
  private static final String ACTION_SHARE_VIA_TWITTER_EVENT = "shareViaTwitter";
  private static final String ACTION_SHARE_VIA_FACEBOOK_EVENT = "shareViaFacebook";
  private static final String ACTION_SHARE_VIA_FACEBOOK_WITH_PASTEMESSAGEHINT = "shareViaFacebookWithPasteMessageHint";
  private static final String ACTION_SHARE_VIA_WHATSAPP_EVENT = "shareViaWhatsApp";
  private static final String ACTION_SHARE_VIA_SMS_EVENT = "shareViaSMS";
  private static final String ACTION_SHARE_VIA_EMAIL_EVENT = "shareViaEmail";

  private static final int ACTIVITY_CODE_SENDVIAEMAIL = 2;

  private CallbackContext _callbackContext;

  private String pasteMessage;

  private abstract class SocialSharingRunnable implements Runnable {
    public CallbackContext callbackContext;
    SocialSharingRunnable(CallbackContext cb) {
      this.callbackContext = cb;
    }
  }

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    this._callbackContext = callbackContext; // only used for onActivityResult
    this.pasteMessage = null;
    if (ACTION_AVAILABLE_EVENT.equals(action)) {
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
      return true;
    } else if (ACTION_SHARE_EVENT.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), null, false);
    } else if (ACTION_SHARE_VIA_TWITTER_EVENT.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), "twitter", false);
    } else if (ACTION_SHARE_VIA_FACEBOOK_EVENT.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), "com.facebook.katana", false);
    } else if (ACTION_SHARE_VIA_FACEBOOK_WITH_PASTEMESSAGEHINT.equals(action)) {
      this.pasteMessage = args.getString(4);
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), "com.facebook.katana", false);
    } else if (ACTION_SHARE_VIA_WHATSAPP_EVENT.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), "whatsapp", false);
    } else if (ACTION_CAN_SHARE_VIA.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), args.getString(4), true);
    } else if (ACTION_CAN_SHARE_VIA_EMAIL.equals(action)) {
      if (isEmailAvailable()) {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        return true;
      } else {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "not available"));
        return false;
      }
    } else if (ACTION_SHARE_VIA.equals(action)) {
      return doSendIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.getString(3), args.getString(4), false);
    } else if (ACTION_SHARE_VIA_SMS_EVENT.equals(action)) {
      return invokeSMSIntent(callbackContext, args.getJSONObject(0), args.getString(1));
    } else if (ACTION_SHARE_VIA_EMAIL_EVENT.equals(action)) {
      return invokeEmailIntent(callbackContext, args.getString(0), args.getString(1), args.getJSONArray(2), args.isNull(3) ? null : args.getJSONArray(3), args.isNull(4) ? null : args.getJSONArray(4), args.isNull(5) ? null : args.getJSONArray(5));
    } else {
      callbackContext.error("socialSharing." + action + " is not a supported function. Did you mean '" + ACTION_SHARE_EVENT + "'?");
      return false;
    }
  }

  private boolean isEmailAvailable() {
    final Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "someone@domain.com", null));
    return cordova.getActivity().getPackageManager().queryIntentActivities(intent, 0).size() > 0;
  }

  private boolean invokeEmailIntent(final CallbackContext callbackContext, final String message, final String subject, final JSONArray to, final JSONArray cc, final JSONArray bcc, final JSONArray files) throws JSONException {

    final SocialSharing plugin = this;
    cordova.getThreadPool().execute(new SocialSharingRunnable(callbackContext) {
      public void run() {
        final Intent draft = new Intent(Intent.ACTION_SEND_MULTIPLE);
        if (notEmpty(message)) {
          Pattern htmlPattern = Pattern.compile(".*\\<[^>]+>.*", Pattern.DOTALL);
          if (htmlPattern.matcher(message).matches()) {
            draft.putExtra(android.content.Intent.EXTRA_TEXT, Html.fromHtml(message));
            draft.setType("text/html");
          } else {
            draft.putExtra(android.content.Intent.EXTRA_TEXT, message);
            draft.setType("text/plain");
          }
        }
        if (notEmpty(subject)) {
          draft.putExtra(android.content.Intent.EXTRA_SUBJECT, subject);
        }
        try {
          if (to != null && to.length() > 0) {
            draft.putExtra(android.content.Intent.EXTRA_EMAIL, toStringArray(to));
          }
          if (cc != null && cc.length() > 0) {
            draft.putExtra(android.content.Intent.EXTRA_CC, toStringArray(cc));
          }
          if (bcc != null && bcc.length() > 0) {
            draft.putExtra(android.content.Intent.EXTRA_BCC, toStringArray(bcc));
          }
          if (files.length() > 0) {
            ArrayList<Uri> fileUris = new ArrayList<Uri>();
            final String dir = getDownloadDir();
            for (int i = 0; i < files.length(); i++) {
              final Uri fileUri = getFileUriAndSetType(draft, dir, files.getString(i), subject, i);
              if (fileUri != null) {
                fileUris.add(fileUri);
              }
            }
            if (!fileUris.isEmpty()) {
              draft.putExtra(Intent.EXTRA_STREAM, fileUris);
            }
          }
        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }

        draft.setType("application/octet-stream");
        cordova.startActivityForResult(plugin, Intent.createChooser(draft, "Choose Email App"), ACTIVITY_CODE_SENDVIAEMAIL);
      }
    });

    return true;
  }

  private String getDownloadDir() throws IOException {
    final String dir = webView.getContext().getExternalFilesDir(null) + "/socialsharing-downloads"; // external

//    final String dir = webView.getContext().getCacheDir() + "/socialsharing-downloads"; // internal (no external permission needed)
    createOrCleanDir(dir);
    return dir;
  }

  private boolean doSendIntent(final CallbackContext callbackContext, final String msg, final String subject, final JSONArray files, final String url, final String appPackageName, final boolean peek) {

    final CordovaInterface mycordova = cordova;
    final CordovaPlugin plugin = this;

    cordova.getThreadPool().execute(new SocialSharingRunnable(callbackContext) {
      public void run() {
        String message = msg;
        final boolean hasMultipleAttachments = files.length() > 1;
        final Intent sendIntent = new Intent(hasMultipleAttachments ? Intent.ACTION_SEND_MULTIPLE : Intent.ACTION_SEND);
        sendIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);

        if (files.length() > 0) {
          ArrayList<Uri> fileUris = new ArrayList<Uri>();
          try {
            final String dir = getDownloadDir();
            Uri fileUri = null;
            for (int i = 0; i < files.length(); i++) {
              fileUri = getFileUriAndSetType(sendIntent, dir, files.getString(i), subject, i);
              if (fileUri != null) {
                fileUris.add(fileUri);
              }
            }
            if (!fileUris.isEmpty()) {
              if (hasMultipleAttachments) {
                sendIntent.putExtra(Intent.EXTRA_STREAM, fileUris);
              } else {
                sendIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
              }
            }
          } catch (Exception e) {
            callbackContext.error(e.getMessage());
          }
        } else {
          sendIntent.setType("text/plain");
        }

        if (notEmpty(subject)) {
          sendIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        }
        // add the URL to the message, as there seems to be no separate field
        if (notEmpty(url)) {
          if (notEmpty(message)) {
            message += " " + url;
          } else {
            message = url;
          }
        }
        if (notEmpty(message)) {
          sendIntent.putExtra(android.content.Intent.EXTRA_TEXT, message);
          sendIntent.putExtra("sms_body", message); // sometimes required when the user picks share via sms
        }

        if (appPackageName != null) {
          String packageName = appPackageName;
          String passedActivityName = null;
          if (packageName.contains("/")) {
            String[] items = appPackageName.split("/");
            packageName = items[0];
            passedActivityName = items[1];
          }
          final ActivityInfo activity = getActivity(callbackContext, sendIntent, packageName);
          if (activity != null) {
            if (peek) {
              callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            } else {
              sendIntent.addCategory(Intent.CATEGORY_LAUNCHER);
              sendIntent.setComponent(new ComponentName(activity.applicationInfo.packageName,
                  passedActivityName != null ? passedActivityName : activity.name));
              mycordova.startActivityForResult(plugin, sendIntent, 0);

              if (pasteMessage != null) {
                // add a little delay because target app (facebook only atm) needs to be started first
                new Timer().schedule(new TimerTask() {
                  public void run() {
                    cordova.getActivity().runOnUiThread(new Runnable() {
                      public void run() {
                        showPasteMessage(msg, pasteMessage);
                      }
                    });
                  }
                }, 2000);
              }
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
    });
    return true;
  }

  @SuppressLint("NewApi")
  private void showPasteMessage(String msg, String label) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
      return;
    }
    // copy to clipboard
    final ClipboardManager clipboard = (android.content.ClipboardManager) cordova.getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
    final ClipData clip = android.content.ClipData.newPlainText(label, msg);
    clipboard.setPrimaryClip(clip);

    // show a toast
    final Toast toast = Toast.makeText(webView.getContext(), label, Toast.LENGTH_LONG);
    toast.setGravity(Gravity.CENTER_VERTICAL | Gravity.CENTER_HORIZONTAL, 0, 0);
    toast.show();
  }

  private Uri getFileUriAndSetType(Intent sendIntent, String dir, String image, String subject, int nthFile) throws IOException {
    // we're assuming an image, but this can be any filetype you like
    String localImage = image;
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
      // safeguard for https://code.google.com/p/android/issues/detail?id=7901#c43
      if (!image.contains(";base64,")) {
        sendIntent.setType("text/plain");
        return null;
      }
      // image looks like this: data:image/png;base64,R0lGODlhDAA...
      final String encodedImg = image.substring(image.indexOf(";base64,") + 8);
      // correct the intent type if anything else was passed, like a pdf: data:application/pdf;base64,..
      if (!image.contains("data:image/")) {
        sendIntent.setType(image.substring(image.indexOf("data:") + 5, image.indexOf(";base64")));
      }
      // the filename needs a valid extension, so it renders correctly in target apps
      final String imgExtension = image.substring(image.indexOf("/") + 1, image.indexOf(";base64"));
      String fileName;
      // if a subject was passed, use it as the filename
      // filenames must be unique when passing in multiple files [#158]
      if (notEmpty(subject)) {
        fileName = sanitizeFilename(subject) + (nthFile == 0 ? "" : "_" + nthFile) + "." + imgExtension;
      } else {
        fileName = "file" + (nthFile == 0 ? "" : "_" + nthFile) + "." + imgExtension;
      }
      saveFile(Base64.decode(encodedImg, Base64.DEFAULT), dir, fileName);
      localImage = "file://" + dir + "/" + fileName;
    } else if (!image.startsWith("file://")) {
      throw new IllegalArgumentException("URL_NOT_SUPPORTED");
    }
    return Uri.parse(localImage);
  }

  private boolean invokeSMSIntent(final CallbackContext callbackContext, JSONObject options, String p_phonenumbers) {
    final String message = options.optString("message");
    // TODO test this on a real SMS enabled device before releasing it
//    final String subject = options.optString("subject");
//    final String image = options.optString("image");
    final String subject = null; //options.optString("subject");
    final String image = null; // options.optString("image");
    final String phonenumbers = getPhoneNumbersWithManufacturerSpecificSeparators(p_phonenumbers);
    final SocialSharing plugin = this;
    cordova.getThreadPool().execute(new SocialSharingRunnable(callbackContext) {
      public void run() {
        Intent intent;

        if (Build.VERSION.SDK_INT >= 19) { // Build.VERSION_CODES.KITKAT) {
          // passing in no phonenumbers for kitkat may result in an error,
          // but it may also work for some devices, so documentation will need to cover this case
          intent = new Intent(Intent.ACTION_SENDTO);
          intent.setData(Uri.parse("smsto:" + (notEmpty(phonenumbers) ? phonenumbers : "")));
        } else {
          intent = new Intent(Intent.ACTION_VIEW);
          intent.setType("vnd.android-dir/mms-sms");
          if (phonenumbers != null) {
            intent.putExtra("address", phonenumbers);
          }
        }
        intent.putExtra("sms_body", message);
        intent.putExtra("sms_subject", subject);

        try {
          if (image != null && !"".equals(image)) {
            final Uri fileUri = getFileUriAndSetType(intent, getDownloadDir(), image, subject, 0);
            if (fileUri != null) {
              intent.putExtra(Intent.EXTRA_STREAM, fileUri);
            }
          }
          cordova.startActivityForResult(plugin, intent, 0);
        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
    return true;
  }

  private static String getPhoneNumbersWithManufacturerSpecificSeparators(String phonenumbers) {
    if (notEmpty(phonenumbers)) {
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

  private ActivityInfo getActivity(final CallbackContext callbackContext, final Intent shareIntent, final String appPackageName) {
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

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    if (_callbackContext != null) {
      if (ACTIVITY_CODE_SENDVIAEMAIL == requestCode) {
        _callbackContext.success();
      } else {
        _callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, resultCode == Activity.RESULT_OK));
      }
    }
  }

  private void createOrCleanDir(final String downloadDir) throws IOException {
    final File dir = new File(downloadDir);
    if (!dir.exists()) {
      if (!dir.mkdirs()) {
        throw new IOException("CREATE_DIRS_FAILED");
      }
    } else {
      cleanupOldFiles(dir);
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

  private static boolean notEmpty(String what) {
    return what != null &&
        !"".equals(what) &&
        !"null".equalsIgnoreCase(what);
  }

  private static String[] toStringArray(JSONArray jsonArray) throws JSONException {
    String[] result = new String[jsonArray.length()];
    for (int i = 0; i < jsonArray.length(); i++) {
      result[i] = jsonArray.getString(i);
    }
    return result;
  }

  public static String sanitizeFilename(String name) {
    return name.replaceAll("[:\\\\/*?|<> ]", "_");
  }
}
