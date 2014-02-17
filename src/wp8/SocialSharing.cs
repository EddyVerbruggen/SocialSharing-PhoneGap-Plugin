using Microsoft.Phone.Tasks;

using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;

namespace Cordova.Extension.Commands {
	public class SocialSharing : BaseCommand {
		public void share(string jsonArgs) {

      var options = JsonHelper.Deserialize<string[]>(jsonArgs);

      var message = options[0];
      var title = options[1];
      var image = options[2];
      var link = options[3];

      if (!"null".Equals(link))
      {
        ShareLinkTask shareLinkTask = new ShareLinkTask();
        shareLinkTask.Title = title;
        shareLinkTask.LinkUri = new System.Uri(link, System.UriKind.Absolute);
        shareLinkTask.Message = message;
        shareLinkTask.Show();
      }
      else if (!"null".Equals(image))
      {
        ShareLinkTask shareLinkTask = new ShareLinkTask();
        shareLinkTask.Title = title;
        shareLinkTask.LinkUri = new System.Uri(image, System.UriKind.Absolute);
        shareLinkTask.Message = message;
        shareLinkTask.Show();
      }
      else
      {
        var shareStatusTask = new ShareStatusTask { Status = message };
        shareStatusTask.Show();
      }
      // unfortunately, there is no way to tell if something was shared, so just invoke the successCallback
			DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
		}
	}
}