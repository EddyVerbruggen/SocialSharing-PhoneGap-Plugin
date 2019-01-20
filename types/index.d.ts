// Type definitions for PhoneGap / Cordova Social Sharing plugin
// Project: https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin
// Licensed under the MIT license.

interface Window {
	plugins: Plugins
}

interface Plugins {
	socialsharing: SocialSharing
}

interface Navigator {
	share: SocialSharingW3C
}

declare class SocialSharing {
	iPadPopupCoordinates: () => string
	setIPadPopupCoordinates: (coords: string) => void
	available: (callback: (available: boolean) => void) => void
	shareWithOptions: (options: Options, successCallback: SocialSharingSuccessCallback, errorCallback: SocialSharingErrorCallback) => void
	shareW3C: SocialSharingW3C
	share: (message: string | undefined, subject: string | undefined, fileOrFileArray: string | ArrayLike<string> | undefined, url: string | undefined, successCallback: SocialSharingSuccessCallback, errorCallback: SocialSharingErrorCallback) => void
	shareViaTwitter: (message: string | undefined, file: string | undefined, url: string | undefined, successCallback: SocialSharingSuccessCallback, errorCallback: SocialSharingErrorCallback) => void
	shareViaFacebook: (message: string | undefined, fileOrFileArray: string | ArrayLike<string> | undefined, url: string | undefined, successCallback: SocialSharingSuccessCallback, errorCallback: SocialSharingErrorCallback) => void
}

type SocialSharingW3C = (shareData: SocialSharingW3CData) => Promise<SocialSharingResult>

interface SocialSharingW3CData {
	title?: string
	text?: string
	url?: string
}

interface Options {
	message?: string
	subject?: string
	files?: ArrayLike<string>
	url?: string
	chooserTitle?: string
	appPackageName?: string
}

type SocialSharingSuccessCallback = (result: SocialSharingResult) => void
type SocialSharingErrorCallback = (msg: string) => void

interface SocialSharingResult {
	completed: boolean
	app?: string
}
