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
	shareWithOptions: (options: SocialSharingOptions, successCallback?: SocialSharingSuccessCallback<SocialSharingResult>, errorCallback?: SocialSharingErrorCallback) => void
	shareW3C: SocialSharingW3C
	share: (message?: string, subject?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaTwitter: (message?: string, file?: string, url?: string, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaFacebook: (message?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaFacebookWithPasteMessageHint: (message?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, pasteMessageHint?: string, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaWhatsApp: (message?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaWhatsAppToReceiver: (receiver?: string, message?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaWhatsAppToPhone: (phone?: string, message?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaSMS: (options?: SocialSharingOptions | string, phoneNumbers?: ArrayLike<string>, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaEmail: (message?: string, subject?: string, toArray?: ArrayLike<string>, ccArray?: ArrayLike<string>, bccArray?: ArrayLike<string>, fileOrFileArray?: string | ArrayLike<string>, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	canShareVia: (via: string, message?: string, subject?: string, fileOrFileArray?: string | ArrayLike<string>, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	canShareViaEmail: (successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	shareViaInstagram: (message?: string, fileOrFileArray?: string | ArrayLike<string>, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
	shareVia: (via: string, message?: string, subject?: string, fileOrFileArray?: string | ArrayLike<string>, url?: string, successCallback?: SocialSharingSuccessCallback<boolean>, errorCallback?: SocialSharingErrorCallback) => void
	saveToPhotoAlbum: (fileOrFileArray?: string | ArrayLike<string>, successCallback?: SocialSharingSuccessCallback<never>, errorCallback?: SocialSharingErrorCallback) => void
}

type SocialSharingW3C = (shareData: SocialSharingW3CData) => Promise<SocialSharingResult>

interface SocialSharingW3CData {
	title?: string
	text?: string
	url?: string
}

interface SocialSharingOptions {
	message?: string
	subject?: string
	files?: ArrayLike<string>
	url?: string
	chooserTitle?: string
	appPackageName?: string
}

type SocialSharingSuccessCallback<T> = (result: T) => void
type SocialSharingErrorCallback = (msg?: string) => void

interface SocialSharingResult {
	completed: boolean
	app?: string
}
