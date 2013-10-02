package nl.xservices.plugins;

import android.content.Intent;
import android.net.Uri;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.*;
import java.net.URL;

public class SocialSharing extends CordovaPlugin {

  private static final String ACTION_AVAILABLE_EVENT = "available";
  private static final String ACTION_SHARE_EVENT = "share";

  File downloadedFile;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    try {
      if (ACTION_AVAILABLE_EVENT.equals(action)) {
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        return true;
      } else if (ACTION_SHARE_EVENT.equals(action)) {
        final String message = args.getString(0);
        final String subject = args.getString(1);
        final String image = args.getString(2);
        final String url = args.getString(3);
        doSendIntent(subject, message, image, url);
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
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

  private void doSendIntent(String subject, String message, String image, String url) throws IOException {
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

    this.cordova.startActivityForResult(this, sendIntent, 0);
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