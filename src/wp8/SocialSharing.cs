using Microsoft.Phone.Tasks;

using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;

namespace Cordova.Extension.Commands {
	public class SocialSharing : BaseCommand {
		public void share(string jsonArgs) {
			var message = JsonHelper.Deserialize<string[]>(jsonArgs)[0];
			var shareStatusTask = new ShareStatusTask { Status = message };
			shareStatusTask.Show();
			DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
		}
	}
}