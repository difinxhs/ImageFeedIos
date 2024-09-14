import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

    func logout() {
        cleanCookies()
        cleanToken()
        cleanImagesList()
    }

   private func cleanCookies() {
      // Очищаем все куки из хранилища
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      // Запрашиваем все данные из локального хранилища
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         // Массив полученных записей удаляем из хранилища
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
    
    private func cleanToken() {
        KeychainWrapper.standard.removeObject(forKey: "OAuth2Token")
        print("Token removed")
    }
    
    private func cleanProfile() {
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatarURL()
    }
    
    private func cleanImagesList() {
        ImagesListService.shared.cleanPhotosList()
    }
}

    
