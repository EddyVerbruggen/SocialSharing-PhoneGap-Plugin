using Microsoft.Phone.Tasks;

using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;

namespace Cordova.Extension.Commands {
	public class SocialSharing : BaseCommand {

    public void available(string jsonArgs) {
			DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
    }

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

    public void canShareViaEmail(string jsonArgs) {
			DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
    }

    // HTML and attachments are currently not supported on WP8
    public void shareViaEmail(string jsonArgs) {
      string[] args = JsonHelper.Deserialize<string[]>(jsonArgs);
      EmailOptions options = JsonHelper.Deserialize<Options>(args[0]);

      EmailComposeTask draft = new EmailComposeTask();
      draft.Body = options.Body;
      draft.Subject = options.Subject;
      if (options.To != null) {
        draft.To = string.Join(",", options.To);
      }
      if (options.Cc != null) {
        draft.Cc = string.Join(",", options.Cc);
      }
      if (options.Bcc != null) {
        draft.Bcc = string.Join(",", options.Bcc);
      }
      draft.Show();
      DispatchCommandResult(new PluginResult(PluginResult.Status.OK, true));
     }

     [DataContract]
     class EmailOptions {
       [DataMember(IsRequired = false, Name = "message")]
       public string Body { get; set; }

       [DataMember(IsRequired = false, Name = "subject")]
       public string Subject { get; set; }

       [DataMember(IsRequired = false, Name = "toArray")]
       public string[] To { get; set; }

       [DataMember(IsRequired = false, Name = "ccArray")]
       public string[] Cc { get; set; }

       [DataMember(IsRequired = false, Name = "bccArray")]
       public string[] Bcc { get; set; }
     }
	}
}