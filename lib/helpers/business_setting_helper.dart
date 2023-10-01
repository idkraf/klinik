import 'package:klinikkecantikan/data_model/business_setting_response.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:klinikkecantikan/repositories/business_setting_repository.dart';
import 'package:klinikkecantikan/providers/locale_provider.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

class BusinessSettingHelper {
  setBusinessSettingData() async {
    List<BusinessSettingListResponse> businessLists =
        await BusinessSettingRepository().getBusinessSettingList();


    businessLists.forEach((element) {
      switch (element.type) {
        case 'club_point':
          {
            if (element.value.toString() == "1") {
              club_point_addon_installed.$ = true;
            } else {
              club_point_addon_installed.$ = false;
            }
          }
          break;
        case 'affiliate_system':
          {
            if (element.value.toString() == "1") {
              affiliate_system_addon_installed.$ = true;
            } else {
              affiliate_system_addon_installed.$ = false;
            }
          }
          break;
        case 'refund_request':
          {
            if (element.value.toString() == "1") {
              refund_addon_installed.$ = true;
            } else {
              refund_addon_installed.$ = false;
            }
          }
          break;
        case 'otp_system':
          {
            if (element.value.toString() == "1") {
              otp_addon_installed.$ = true;
            } else {
              otp_addon_installed.$ = false;
            }
          }
          break;
        case 'multi_login':
          {
            if (element.value.toString() == "1") {
              allow_facebook_login.$ = true;
            } else {
              allow_facebook_login.$ = false;
            }
          }
          break;
        case 'facebook_login':
          {
            if (element.value.toString() == "1") {
              allow_facebook_login.$ = true;
            } else {
              allow_facebook_login.$ = false;
            }
          }
          break;
        case 'google_login':
          {
            if (element.value.toString() == "1") {
              allow_google_login.$ = true;
            } else {
              allow_google_login.$ = false;
            }
          }
          break;
        case 'twitter_login':
          {
            if (element.value.toString() == "1") {
              allow_twitter_login.$ = true;
            } else {
              allow_twitter_login.$ = false;
            }
          }
          break;
        case 'pickup_point':
          {
            if (element.value.toString() == "1") {
              pick_up_status.$ = true;
            } else {
              pick_up_status.$ = false;
            }
          }
          break;
        case 'wallet_system':
          {
            if (element.value.toString() == "1") {
              wallet_system_status.$ = true;
            } else {
              wallet_system_status.$ = false;
            }
          }
          break;
        case 'email_verification':
          {
            if (element.value.toString() == "1") {
              mail_verification_status.$ = true;
            } else {
              mail_verification_status.$ = false;
            }
          }
          break;
        case 'conversation_system':
          {
            if (element.value.toString() == "1") {
              conversation_system_status.$ = true;
            } else {
              conversation_system_status.$ = false;
            }
          }
          break;
        case 'shipping_type':
          {
            print(element.value.toString());
            if (element.value.toString() == "carrier_wise_shipping") {
              carrier_base_shipping.$ = true;
            } else {
              carrier_base_shipping.$ = false;
            }
          }
          break;
        case 'system_shop':
          {
            if (element.value.toString() == "1") {
              allow_multivendor.$ = true;
            } else {
              allow_multivendor.$ = false;
            }
          }
          break;

        case 'club_point_convert_rate':
          {
            print(element.value.toString());
            club_point_convert_rate.$ = element.value.toString();
          }
          break;
        default:
          {}
          break;
      }
    });
  }
}
