import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @priceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLow;

  /// No description provided for @priceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHigh;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get available;

  /// No description provided for @noItemsToSell.
  ///
  /// In en, this message translates to:
  /// **'No items to sell'**
  String get noItemsToSell;

  /// No description provided for @noItemsToBuy.
  ///
  /// In en, this message translates to:
  /// **'No items to buy'**
  String get noItemsToBuy;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get harvest;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Lands'**
  String get land;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicle;

  /// No description provided for @machineries.
  ///
  /// In en, this message translates to:
  /// **'Machineries'**
  String get machineries;

  /// No description provided for @culitivation.
  ///
  /// In en, this message translates to:
  /// **'Cultivation'**
  String get culitivation;

  /// No description provided for @agrochems.
  ///
  /// In en, this message translates to:
  /// **'Agrochemicals'**
  String get agrochems;

  /// No description provided for @fertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get fertilizers;

  /// No description provided for @agriEquipment.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Equipment'**
  String get agriEquipment;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animal Husbandry and Productions'**
  String get animals;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @selling.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get selling;

  /// No description provided for @buying.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get buying;

  /// No description provided for @seeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds, Plants and Planting Material'**
  String get seeds;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Foreign Market'**
  String get market;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @fourlegs.
  ///
  /// In en, this message translates to:
  /// **'Quadrupeds'**
  String get fourlegs;

  /// No description provided for @twolegs.
  ///
  /// In en, this message translates to:
  /// **'Bipeds'**
  String get twolegs;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @goda.
  ///
  /// In en, this message translates to:
  /// **'Estate & Garden'**
  String get goda;

  /// No description provided for @mada.
  ///
  /// In en, this message translates to:
  /// **'Mud Lands'**
  String get mada;

  /// No description provided for @landMasters.
  ///
  /// In en, this message translates to:
  /// **'Land Masters'**
  String get landMasters;

  /// No description provided for @tractors.
  ///
  /// In en, this message translates to:
  /// **'Tractors'**
  String get tractors;

  /// No description provided for @spareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts'**
  String get spareParts;

  /// No description provided for @itemAddAlert.
  ///
  /// In en, this message translates to:
  /// **'You have added a new item.'**
  String get itemAddAlert;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get kg;

  /// No description provided for @priceForOnekg.
  ///
  /// In en, this message translates to:
  /// **'Price for 1KG'**
  String get priceForOnekg;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @dso.
  ///
  /// In en, this message translates to:
  /// **'D.S.O'**
  String get dso;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name*'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Enter your address*'**
  String get address;

  /// No description provided for @mob1.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number1*'**
  String get mob1;

  /// No description provided for @mob2.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number2'**
  String get mob2;

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addItems;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'Enter your NIC number(only numbers)*'**
  String get id;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This filed can\'t be empty'**
  String get required;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @districtSelectionTopic.
  ///
  /// In en, this message translates to:
  /// **'Select Your District and Divisional Secretariat'**
  String get districtSelectionTopic;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @intro1.
  ///
  /// In en, this message translates to:
  /// **'Register in this \'Aswanna\' app to get all the inforamtion for your farming and enjoy their benifits.'**
  String get intro1;

  /// No description provided for @intro2.
  ///
  /// In en, this message translates to:
  /// **'After entering your personal information, you will also become a qualified person to use this app.'**
  String get intro2;

  /// No description provided for @intro3.
  ///
  /// In en, this message translates to:
  /// **'All your personal information will not go into the hands of thirdpatry, except your phone number, name and your area. Only your buyers and suppliers will contact you.'**
  String get intro3;

  /// No description provided for @labour.
  ///
  /// In en, this message translates to:
  /// **'Consultancy and service providers'**
  String get labour;

  /// No description provided for @intro1_topic.
  ///
  /// In en, this message translates to:
  /// **'What is this app?'**
  String get intro1_topic;

  /// No description provided for @districSelectorAlert.
  ///
  /// In en, this message translates to:
  /// **'Please select your District and Divisional Secretariat.'**
  String get districSelectorAlert;

  /// No description provided for @specialInfo.
  ///
  /// In en, this message translates to:
  /// **'Special Information'**
  String get specialInfo;

  /// No description provided for @sucessMzg.
  ///
  /// In en, this message translates to:
  /// **'User Registered Successfully'**
  String get sucessMzg;

  /// No description provided for @errorMzg.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error occurred'**
  String get errorMzg;

  /// No description provided for @intro_new.
  ///
  /// In en, this message translates to:
  /// **'Farmers face many challenges today, including a lack of knowledge about cultivation and unfair pricing for their harvests. This app provides a solution to these problems.'**
  String get intro_new;

  /// No description provided for @intro_new2.
  ///
  /// In en, this message translates to:
  /// **'Using this app, we aim to solve the problems faced by all kinds of farmers.'**
  String get intro_new2;

  /// No description provided for @intro2_topic.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get intro2_topic;

  /// No description provided for @intro3_topic.
  ///
  /// In en, this message translates to:
  /// **'Therefore'**
  String get intro3_topic;

  /// No description provided for @intro4_topic.
  ///
  /// In en, this message translates to:
  /// **'For that'**
  String get intro4_topic;

  /// No description provided for @intro5_topic.
  ///
  /// In en, this message translates to:
  /// **'But'**
  String get intro5_topic;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @productions.
  ///
  /// In en, this message translates to:
  /// **'Processed Productions'**
  String get productions;

  /// No description provided for @fertilizers_tab1.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get fertilizers_tab1;

  /// No description provided for @fertilizers_tab2.
  ///
  /// In en, this message translates to:
  /// **'Non-organic'**
  String get fertilizers_tab2;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @perches.
  ///
  /// In en, this message translates to:
  /// **'Perches'**
  String get perches;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @otherdetails.
  ///
  /// In en, this message translates to:
  /// **'Other details'**
  String get otherdetails;

  /// No description provided for @eravurPattu.
  ///
  /// In en, this message translates to:
  /// **'Eravur Pattu'**
  String get eravurPattu;

  /// No description provided for @eravurTown.
  ///
  /// In en, this message translates to:
  /// **'Eravur Town'**
  String get eravurTown;

  /// No description provided for @kattankudy.
  ///
  /// In en, this message translates to:
  /// **'Kattankudy'**
  String get kattankudy;

  /// No description provided for @koralaiPattu.
  ///
  /// In en, this message translates to:
  /// **'Koralai Pattu'**
  String get koralaiPattu;

  /// No description provided for @koralaiPattuCentral.
  ///
  /// In en, this message translates to:
  /// **'Koralai Pattu Central'**
  String get koralaiPattuCentral;

  /// No description provided for @koralaiPattuNorth.
  ///
  /// In en, this message translates to:
  /// **'Koralai Pattu North'**
  String get koralaiPattuNorth;

  /// No description provided for @koralaiPattuSouth.
  ///
  /// In en, this message translates to:
  /// **'Koralai Pattu South'**
  String get koralaiPattuSouth;

  /// No description provided for @koralaiPattuWest.
  ///
  /// In en, this message translates to:
  /// **'Koralai Pattu West'**
  String get koralaiPattuWest;

  /// No description provided for @manmunaiNorth.
  ///
  /// In en, this message translates to:
  /// **'Manmunai North'**
  String get manmunaiNorth;

  /// No description provided for @manmunaiPattu.
  ///
  /// In en, this message translates to:
  /// **'Manmunai Pattu'**
  String get manmunaiPattu;

  /// No description provided for @manmunaiSAndEruvilPattu.
  ///
  /// In en, this message translates to:
  /// **'Manmunai S. and Eruvil Pattu'**
  String get manmunaiSAndEruvilPattu;

  /// No description provided for @manmunaiSouthWest.
  ///
  /// In en, this message translates to:
  /// **'Manmunai South West'**
  String get manmunaiSouthWest;

  /// No description provided for @manmunaiWest.
  ///
  /// In en, this message translates to:
  /// **'Manmunai West'**
  String get manmunaiWest;

  /// No description provided for @porativuPattu.
  ///
  /// In en, this message translates to:
  /// **'Porativu Pattu'**
  String get porativuPattu;

  /// No description provided for @ampara.
  ///
  /// In en, this message translates to:
  /// **'Ampara'**
  String get ampara;

  /// No description provided for @anuradhapura.
  ///
  /// In en, this message translates to:
  /// **'Anuradhapura'**
  String get anuradhapura;

  /// No description provided for @badulla.
  ///
  /// In en, this message translates to:
  /// **'Badulla'**
  String get badulla;

  /// No description provided for @batticaloa.
  ///
  /// In en, this message translates to:
  /// **'Batticaloa'**
  String get batticaloa;

  /// No description provided for @colombo.
  ///
  /// In en, this message translates to:
  /// **'Colombo (35)'**
  String get colombo;

  /// No description provided for @galle.
  ///
  /// In en, this message translates to:
  /// **'Galle'**
  String get galle;

  /// No description provided for @gampaha.
  ///
  /// In en, this message translates to:
  /// **'Gampaha'**
  String get gampaha;

  /// No description provided for @hambantota.
  ///
  /// In en, this message translates to:
  /// **'Hambantota'**
  String get hambantota;

  /// No description provided for @jaffna.
  ///
  /// In en, this message translates to:
  /// **'Jaffna'**
  String get jaffna;

  /// No description provided for @kalutara.
  ///
  /// In en, this message translates to:
  /// **'Kalutara'**
  String get kalutara;

  /// No description provided for @kandy.
  ///
  /// In en, this message translates to:
  /// **'Kandy'**
  String get kandy;

  /// No description provided for @kegalle.
  ///
  /// In en, this message translates to:
  /// **'Kegalle'**
  String get kegalle;

  /// No description provided for @kilinochchi.
  ///
  /// In en, this message translates to:
  /// **'Kilinochchi'**
  String get kilinochchi;

  /// No description provided for @kurunegala.
  ///
  /// In en, this message translates to:
  /// **'Kurunegala'**
  String get kurunegala;

  /// No description provided for @mannar.
  ///
  /// In en, this message translates to:
  /// **'Mannar'**
  String get mannar;

  /// No description provided for @matale.
  ///
  /// In en, this message translates to:
  /// **'Matale'**
  String get matale;

  /// No description provided for @matara.
  ///
  /// In en, this message translates to:
  /// **'Matara'**
  String get matara;

  /// No description provided for @monaragala.
  ///
  /// In en, this message translates to:
  /// **'Monaragala'**
  String get monaragala;

  /// No description provided for @mullaitivu.
  ///
  /// In en, this message translates to:
  /// **'Mullaitivu'**
  String get mullaitivu;

  /// No description provided for @nuwaraEliya.
  ///
  /// In en, this message translates to:
  /// **'Nuwara Eliya'**
  String get nuwaraEliya;

  /// No description provided for @polonnaruwa.
  ///
  /// In en, this message translates to:
  /// **'Polonnaruwa'**
  String get polonnaruwa;

  /// No description provided for @puttalam.
  ///
  /// In en, this message translates to:
  /// **'Puttalam'**
  String get puttalam;

  /// No description provided for @ratnapura.
  ///
  /// In en, this message translates to:
  /// **'Ratnapura'**
  String get ratnapura;

  /// No description provided for @trincomalee.
  ///
  /// In en, this message translates to:
  /// **'Trincomalee'**
  String get trincomalee;

  /// No description provided for @vavuniya.
  ///
  /// In en, this message translates to:
  /// **'Vavuniya'**
  String get vavuniya;

  /// No description provided for @akurana.
  ///
  /// In en, this message translates to:
  /// **'Akurana'**
  String get akurana;

  /// No description provided for @delthota.
  ///
  /// In en, this message translates to:
  /// **'Delthota'**
  String get delthota;

  /// No description provided for @doluwa.
  ///
  /// In en, this message translates to:
  /// **'Doluwa'**
  String get doluwa;

  /// No description provided for @gangawataKorale.
  ///
  /// In en, this message translates to:
  /// **'Gangawata Korale'**
  String get gangawataKorale;

  /// No description provided for @gangaIhalaKorale.
  ///
  /// In en, this message translates to:
  /// **'Ganga Ihala Korale'**
  String get gangaIhalaKorale;

  /// No description provided for @harispattuwa.
  ///
  /// In en, this message translates to:
  /// **'Harispattuwa'**
  String get harispattuwa;

  /// No description provided for @hatharaliyadda.
  ///
  /// In en, this message translates to:
  /// **'Hatharaliyadda'**
  String get hatharaliyadda;

  /// No description provided for @kundasale.
  ///
  /// In en, this message translates to:
  /// **'Kundasale'**
  String get kundasale;

  /// No description provided for @medadumbara.
  ///
  /// In en, this message translates to:
  /// **'Medadumbara'**
  String get medadumbara;

  /// No description provided for @minipe.
  ///
  /// In en, this message translates to:
  /// **'Minipe'**
  String get minipe;

  /// No description provided for @panvila.
  ///
  /// In en, this message translates to:
  /// **'Panvila'**
  String get panvila;

  /// No description provided for @pasbageKorale.
  ///
  /// In en, this message translates to:
  /// **'Pasbage Korale'**
  String get pasbageKorale;

  /// No description provided for @pathadumbara.
  ///
  /// In en, this message translates to:
  /// **'Pathadumbara'**
  String get pathadumbara;

  /// No description provided for @pathahewaheta.
  ///
  /// In en, this message translates to:
  /// **'Pathahewaheta'**
  String get pathahewaheta;

  /// No description provided for @poojapitiya.
  ///
  /// In en, this message translates to:
  /// **'Poojapitiya'**
  String get poojapitiya;

  /// No description provided for @thumpane.
  ///
  /// In en, this message translates to:
  /// **'Thumpane'**
  String get thumpane;

  /// No description provided for @udadumbara.
  ///
  /// In en, this message translates to:
  /// **'Udadumbara'**
  String get udadumbara;

  /// No description provided for @udapalatha.
  ///
  /// In en, this message translates to:
  /// **'Udapalatha'**
  String get udapalatha;

  /// No description provided for @udunuwara.
  ///
  /// In en, this message translates to:
  /// **'Udunuwara'**
  String get udunuwara;

  /// No description provided for @yatinuwara.
  ///
  /// In en, this message translates to:
  /// **'Yatinuwara'**
  String get yatinuwara;

  /// No description provided for @ambangangaKorale.
  ///
  /// In en, this message translates to:
  /// **'Ambanganga Korale'**
  String get ambangangaKorale;

  /// No description provided for @dambulla.
  ///
  /// In en, this message translates to:
  /// **'Dambulla'**
  String get dambulla;

  /// No description provided for @galewela.
  ///
  /// In en, this message translates to:
  /// **'Galewela'**
  String get galewela;

  /// No description provided for @laggalaPallegama.
  ///
  /// In en, this message translates to:
  /// **'Laggala-Pallegama'**
  String get laggalaPallegama;

  /// No description provided for @naula.
  ///
  /// In en, this message translates to:
  /// **'Naula'**
  String get naula;

  /// No description provided for @pallepola.
  ///
  /// In en, this message translates to:
  /// **'Pallepola'**
  String get pallepola;

  /// No description provided for @rattota.
  ///
  /// In en, this message translates to:
  /// **'Rattota'**
  String get rattota;

  /// No description provided for @ukuwela.
  ///
  /// In en, this message translates to:
  /// **'Ukuwela'**
  String get ukuwela;

  /// No description provided for @wilgamuwa.
  ///
  /// In en, this message translates to:
  /// **'Wilgamuwa'**
  String get wilgamuwa;

  /// No description provided for @yatawatta.
  ///
  /// In en, this message translates to:
  /// **'Yatawatta'**
  String get yatawatta;

  /// No description provided for @ambagamuwa.
  ///
  /// In en, this message translates to:
  /// **'Ambagamuwa'**
  String get ambagamuwa;

  /// No description provided for @hanguranketha.
  ///
  /// In en, this message translates to:
  /// **'Hanguranketha'**
  String get hanguranketha;

  /// No description provided for @kothmale.
  ///
  /// In en, this message translates to:
  /// **'Kothmale'**
  String get kothmale;

  /// No description provided for @kothmaleWest.
  ///
  /// In en, this message translates to:
  /// **'Kothmale West'**
  String get kothmaleWest;

  /// No description provided for @mathurata.
  ///
  /// In en, this message translates to:
  /// **'Mathurata'**
  String get mathurata;

  /// No description provided for @nildandahinna.
  ///
  /// In en, this message translates to:
  /// **'Nildandahinna'**
  String get nildandahinna;

  /// No description provided for @norwood.
  ///
  /// In en, this message translates to:
  /// **'Norwood'**
  String get norwood;

  /// No description provided for @thalawakale.
  ///
  /// In en, this message translates to:
  /// **'Thalawakale'**
  String get thalawakale;

  /// No description provided for @walapane.
  ///
  /// In en, this message translates to:
  /// **'Walapane'**
  String get walapane;

  /// No description provided for @addalachchena.
  ///
  /// In en, this message translates to:
  /// **'Addalachchena'**
  String get addalachchena;

  /// No description provided for @akkaraipattu.
  ///
  /// In en, this message translates to:
  /// **'Akkaraipattu'**
  String get akkaraipattu;

  /// No description provided for @alayadiwembu.
  ///
  /// In en, this message translates to:
  /// **'Alayadiwembu'**
  String get alayadiwembu;

  /// No description provided for @damana.
  ///
  /// In en, this message translates to:
  /// **'Damana'**
  String get damana;

  /// No description provided for @dehiattakandiya.
  ///
  /// In en, this message translates to:
  /// **'Dehiattakandiya'**
  String get dehiattakandiya;

  /// No description provided for @eragama.
  ///
  /// In en, this message translates to:
  /// **'Eragama'**
  String get eragama;

  /// No description provided for @kalmunaiNorth.
  ///
  /// In en, this message translates to:
  /// **'Kalmunai North'**
  String get kalmunaiNorth;

  /// No description provided for @kalmunaiSouth.
  ///
  /// In en, this message translates to:
  /// **'Kalmunai South'**
  String get kalmunaiSouth;

  /// No description provided for @karaitivu.
  ///
  /// In en, this message translates to:
  /// **'Karaitivu'**
  String get karaitivu;

  /// No description provided for @lahugala.
  ///
  /// In en, this message translates to:
  /// **'Lahugala'**
  String get lahugala;

  /// No description provided for @mahaoya.
  ///
  /// In en, this message translates to:
  /// **'Mahaoya'**
  String get mahaoya;

  /// No description provided for @navithanveli.
  ///
  /// In en, this message translates to:
  /// **'Navithanveli'**
  String get navithanveli;

  /// No description provided for @ninthavur.
  ///
  /// In en, this message translates to:
  /// **'Ninthavur'**
  String get ninthavur;

  /// No description provided for @padiyathalawa.
  ///
  /// In en, this message translates to:
  /// **'Padiyathalawa'**
  String get padiyathalawa;

  /// No description provided for @pothuvil.
  ///
  /// In en, this message translates to:
  /// **'Pothuvil'**
  String get pothuvil;

  /// No description provided for @sainthamarathu.
  ///
  /// In en, this message translates to:
  /// **'Sainthamarathu'**
  String get sainthamarathu;

  /// No description provided for @samanthurai.
  ///
  /// In en, this message translates to:
  /// **'Samanthurai'**
  String get samanthurai;

  /// No description provided for @thirukkovil.
  ///
  /// In en, this message translates to:
  /// **'Thirukkovil'**
  String get thirukkovil;

  /// No description provided for @uhana.
  ///
  /// In en, this message translates to:
  /// **'Uhana'**
  String get uhana;

  /// No description provided for @gomarankadawala.
  ///
  /// In en, this message translates to:
  /// **'Gomarankadawala'**
  String get gomarankadawala;

  /// No description provided for @kantalai.
  ///
  /// In en, this message translates to:
  /// **'Kantalai'**
  String get kantalai;

  /// No description provided for @kinniya.
  ///
  /// In en, this message translates to:
  /// **'Kinniya'**
  String get kinniya;

  /// No description provided for @kuchchaveli.
  ///
  /// In en, this message translates to:
  /// **'Kuchchaveli'**
  String get kuchchaveli;

  /// No description provided for @morawewa.
  ///
  /// In en, this message translates to:
  /// **'Morawewa'**
  String get morawewa;

  /// No description provided for @muttur.
  ///
  /// In en, this message translates to:
  /// **'Muttur'**
  String get muttur;

  /// No description provided for @padaviSriPura.
  ///
  /// In en, this message translates to:
  /// **'Padavi Sri Pura'**
  String get padaviSriPura;

  /// No description provided for @seruvila.
  ///
  /// In en, this message translates to:
  /// **'Seruvila'**
  String get seruvila;

  /// No description provided for @thambalagamuwa.
  ///
  /// In en, this message translates to:
  /// **'Thambalagamuwa'**
  String get thambalagamuwa;

  /// No description provided for @verugal.
  ///
  /// In en, this message translates to:
  /// **'Verugal'**
  String get verugal;

  /// No description provided for @galnewa30.
  ///
  /// In en, this message translates to:
  /// **'Galnewa (30)'**
  String get galnewa30;

  /// No description provided for @galenbindunuwewa41.
  ///
  /// In en, this message translates to:
  /// **'Galenbindunuwewa (41)'**
  String get galenbindunuwewa41;

  /// No description provided for @horowpothana38.
  ///
  /// In en, this message translates to:
  /// **'Horowpothana (38)'**
  String get horowpothana38;

  /// No description provided for @ipalogama32.
  ///
  /// In en, this message translates to:
  /// **'Ipalogama (32)'**
  String get ipalogama32;

  /// No description provided for @kahatagasdigiliya40.
  ///
  /// In en, this message translates to:
  /// **'Kahatagasdigiliya (40)'**
  String get kahatagasdigiliya40;

  /// No description provided for @kebithigollewa26.
  ///
  /// In en, this message translates to:
  /// **'Kebithigollewa (26)'**
  String get kebithigollewa26;

  /// No description provided for @kekirawa53.
  ///
  /// In en, this message translates to:
  /// **'Kekirawa (53)'**
  String get kekirawa53;

  /// No description provided for @mahavilachchiya17.
  ///
  /// In en, this message translates to:
  /// **'Mahavilachchiya (17)'**
  String get mahavilachchiya17;

  /// No description provided for @medawachchiya37.
  ///
  /// In en, this message translates to:
  /// **'Medawachchiya (37)'**
  String get medawachchiya37;

  /// No description provided for @mihinthale25.
  ///
  /// In en, this message translates to:
  /// **'Mihinthale (25)'**
  String get mihinthale25;

  /// No description provided for @nachchadoowa19.
  ///
  /// In en, this message translates to:
  /// **'Nachchadoowa (19)'**
  String get nachchadoowa19;

  /// No description provided for @nochchiyagama36.
  ///
  /// In en, this message translates to:
  /// **'Nochchiyagama (36)'**
  String get nochchiyagama36;

  /// No description provided for @nuwaragamPalathaCentral40.
  ///
  /// In en, this message translates to:
  /// **'Nuwaragam Palatha Central (40)'**
  String get nuwaragamPalathaCentral40;

  /// No description provided for @nuwaragamPalathaEast29.
  ///
  /// In en, this message translates to:
  /// **'Nuwaragam Palatha East (29)'**
  String get nuwaragamPalathaEast29;

  /// No description provided for @padaviya15.
  ///
  /// In en, this message translates to:
  /// **'Padaviya (15)'**
  String get padaviya15;

  /// No description provided for @palagala35.
  ///
  /// In en, this message translates to:
  /// **'Palagala (35)'**
  String get palagala35;

  /// No description provided for @palugaswewa16.
  ///
  /// In en, this message translates to:
  /// **'Palugaswewa (16)'**
  String get palugaswewa16;

  /// No description provided for @rajanganaya21.
  ///
  /// In en, this message translates to:
  /// **'Rajanganaya (21)'**
  String get rajanganaya21;

  /// No description provided for @rambewa38.
  ///
  /// In en, this message translates to:
  /// **'Rambewa (38)'**
  String get rambewa38;

  /// No description provided for @thalawa39.
  ///
  /// In en, this message translates to:
  /// **'Thalawa (39)'**
  String get thalawa39;

  /// No description provided for @thambuttegama26.
  ///
  /// In en, this message translates to:
  /// **'Thambuttegama (26)'**
  String get thambuttegama26;

  /// No description provided for @thirappane41.
  ///
  /// In en, this message translates to:
  /// **'Thirappane (41)'**
  String get thirappane41;

  /// No description provided for @dimbulagala.
  ///
  /// In en, this message translates to:
  /// **'Dimbulagala'**
  String get dimbulagala;

  /// No description provided for @elahera.
  ///
  /// In en, this message translates to:
  /// **'Elahera'**
  String get elahera;

  /// No description provided for @hingurakgoda.
  ///
  /// In en, this message translates to:
  /// **'Hingurakgoda'**
  String get hingurakgoda;

  /// No description provided for @lankapura.
  ///
  /// In en, this message translates to:
  /// **'Lankapura'**
  String get lankapura;

  /// No description provided for @medirigiriya.
  ///
  /// In en, this message translates to:
  /// **'Medirigiriya'**
  String get medirigiriya;

  /// No description provided for @thamankaduwa.
  ///
  /// In en, this message translates to:
  /// **'Thamankaduwa'**
  String get thamankaduwa;

  /// No description provided for @welikanda.
  ///
  /// In en, this message translates to:
  /// **'Welikanda'**
  String get welikanda;

  /// No description provided for @delft.
  ///
  /// In en, this message translates to:
  /// **'Delft'**
  String get delft;

  /// No description provided for @islandNorth.
  ///
  /// In en, this message translates to:
  /// **'Island North'**
  String get islandNorth;

  /// No description provided for @islandSouth.
  ///
  /// In en, this message translates to:
  /// **'Island South'**
  String get islandSouth;

  /// No description provided for @karainagar.
  ///
  /// In en, this message translates to:
  /// **'Karainagar'**
  String get karainagar;

  /// No description provided for @nallur.
  ///
  /// In en, this message translates to:
  /// **'Nallur'**
  String get nallur;

  /// No description provided for @thenmaradchi.
  ///
  /// In en, this message translates to:
  /// **'Thenmaradchi'**
  String get thenmaradchi;

  /// No description provided for @vadamaradchiEast.
  ///
  /// In en, this message translates to:
  /// **'Vadamaradchi East'**
  String get vadamaradchiEast;

  /// No description provided for @vadamaradchiNorth.
  ///
  /// In en, this message translates to:
  /// **'Vadamaradchi North'**
  String get vadamaradchiNorth;

  /// No description provided for @vadamaradchiSouthWest.
  ///
  /// In en, this message translates to:
  /// **'Vadamaradchi South-West'**
  String get vadamaradchiSouthWest;

  /// No description provided for @vadamaradchiNorthWest.
  ///
  /// In en, this message translates to:
  /// **'Vadamaradchi North West'**
  String get vadamaradchiNorthWest;

  /// No description provided for @valikamamEast.
  ///
  /// In en, this message translates to:
  /// **'Valikamam East'**
  String get valikamamEast;

  /// No description provided for @valikamamNorth.
  ///
  /// In en, this message translates to:
  /// **'Valikamam North'**
  String get valikamamNorth;

  /// No description provided for @valikamamSouth.
  ///
  /// In en, this message translates to:
  /// **'Valikamam South'**
  String get valikamamSouth;

  /// No description provided for @valikamamSouthWest.
  ///
  /// In en, this message translates to:
  /// **'Valikamam South-West'**
  String get valikamamSouthWest;

  /// No description provided for @valikamamWest.
  ///
  /// In en, this message translates to:
  /// **'Valikamam West'**
  String get valikamamWest;

  /// No description provided for @kandavalai.
  ///
  /// In en, this message translates to:
  /// **'Kandavalai'**
  String get kandavalai;

  /// No description provided for @karachchi.
  ///
  /// In en, this message translates to:
  /// **'Karachchi'**
  String get karachchi;

  /// No description provided for @pachchilaipalli.
  ///
  /// In en, this message translates to:
  /// **'Pachchilaipalli'**
  String get pachchilaipalli;

  /// No description provided for @poonakary.
  ///
  /// In en, this message translates to:
  /// **'Poonakary'**
  String get poonakary;

  /// No description provided for @madhu.
  ///
  /// In en, this message translates to:
  /// **'Madhu'**
  String get madhu;

  /// No description provided for @manthaiWest.
  ///
  /// In en, this message translates to:
  /// **'Manthai West'**
  String get manthaiWest;

  /// No description provided for @musalai.
  ///
  /// In en, this message translates to:
  /// **'Musali'**
  String get musalai;

  /// No description provided for @nanaddan.
  ///
  /// In en, this message translates to:
  /// **'Nanaddan'**
  String get nanaddan;

  /// No description provided for @manthaiEast.
  ///
  /// In en, this message translates to:
  /// **'Manthai East'**
  String get manthaiEast;

  /// No description provided for @maritimepattu.
  ///
  /// In en, this message translates to:
  /// **'Maritimepattu'**
  String get maritimepattu;

  /// No description provided for @oddusuddan.
  ///
  /// In en, this message translates to:
  /// **'Oddusuddan'**
  String get oddusuddan;

  /// No description provided for @puthukudiyiruppu.
  ///
  /// In en, this message translates to:
  /// **'Puthukudiyiruppu'**
  String get puthukudiyiruppu;

  /// No description provided for @thunukkai.
  ///
  /// In en, this message translates to:
  /// **'Thunukkai'**
  String get thunukkai;

  /// No description provided for @welioya.
  ///
  /// In en, this message translates to:
  /// **'Welioya'**
  String get welioya;

  /// No description provided for @vavuniyaNorth.
  ///
  /// In en, this message translates to:
  /// **'Vavuniya North'**
  String get vavuniyaNorth;

  /// No description provided for @vavuniyaSouth.
  ///
  /// In en, this message translates to:
  /// **'Vavuniya South'**
  String get vavuniyaSouth;

  /// No description provided for @vengalacheddikulam.
  ///
  /// In en, this message translates to:
  /// **'Vengalacheddikulam'**
  String get vengalacheddikulam;

  /// No description provided for @alawwa.
  ///
  /// In en, this message translates to:
  /// **'Alawwa'**
  String get alawwa;

  /// No description provided for @ambanpola.
  ///
  /// In en, this message translates to:
  /// **'Ambanpola'**
  String get ambanpola;

  /// No description provided for @bamunakotuwa.
  ///
  /// In en, this message translates to:
  /// **'Bamunakotuwa'**
  String get bamunakotuwa;

  /// No description provided for @bingiriya.
  ///
  /// In en, this message translates to:
  /// **'Bingiriya'**
  String get bingiriya;

  /// No description provided for @ehetuwewa.
  ///
  /// In en, this message translates to:
  /// **'Ehetuwewa'**
  String get ehetuwewa;

  /// No description provided for @galgamuwa.
  ///
  /// In en, this message translates to:
  /// **'Galgamuwa'**
  String get galgamuwa;

  /// No description provided for @ganewatta.
  ///
  /// In en, this message translates to:
  /// **'Ganewatta'**
  String get ganewatta;

  /// No description provided for @giribawa.
  ///
  /// In en, this message translates to:
  /// **'Giribawa'**
  String get giribawa;

  /// No description provided for @ibbagamuwa.
  ///
  /// In en, this message translates to:
  /// **'Ibbagamuwa'**
  String get ibbagamuwa;

  /// No description provided for @katupotha.
  ///
  /// In en, this message translates to:
  /// **'Katupotha'**
  String get katupotha;

  /// No description provided for @kobeigane.
  ///
  /// In en, this message translates to:
  /// **'Kobeigane'**
  String get kobeigane;

  /// No description provided for @kotavehera.
  ///
  /// In en, this message translates to:
  /// **'Kotavehera'**
  String get kotavehera;

  /// No description provided for @kuliyapitiyaEast.
  ///
  /// In en, this message translates to:
  /// **'Kuliyapitiya East'**
  String get kuliyapitiyaEast;

  /// No description provided for @kuliyapitiyaWest.
  ///
  /// In en, this message translates to:
  /// **'Kuliyapitiya West'**
  String get kuliyapitiyaWest;

  /// No description provided for @mahawa.
  ///
  /// In en, this message translates to:
  /// **'Mahawa'**
  String get mahawa;

  /// No description provided for @mallawapitiya.
  ///
  /// In en, this message translates to:
  /// **'Mallawapitiya'**
  String get mallawapitiya;

  /// No description provided for @maspotha.
  ///
  /// In en, this message translates to:
  /// **'Maspotha'**
  String get maspotha;

  /// No description provided for @mawathagama.
  ///
  /// In en, this message translates to:
  /// **'Mawathagama'**
  String get mawathagama;

  /// No description provided for @narammala.
  ///
  /// In en, this message translates to:
  /// **'Narammala'**
  String get narammala;

  /// No description provided for @nikaweratiya.
  ///
  /// In en, this message translates to:
  /// **'Nikaweratiya'**
  String get nikaweratiya;

  /// No description provided for @panduwasnuwara.
  ///
  /// In en, this message translates to:
  /// **'Panduwasnuwara'**
  String get panduwasnuwara;

  /// No description provided for @pannala.
  ///
  /// In en, this message translates to:
  /// **'Pannala'**
  String get pannala;

  /// No description provided for @polgahawela.
  ///
  /// In en, this message translates to:
  /// **'Polgahawela'**
  String get polgahawela;

  /// No description provided for @polpithigama.
  ///
  /// In en, this message translates to:
  /// **'Polpithigama'**
  String get polpithigama;

  /// No description provided for @rasnayakapura.
  ///
  /// In en, this message translates to:
  /// **'Rasnayakapura'**
  String get rasnayakapura;

  /// No description provided for @rideegama.
  ///
  /// In en, this message translates to:
  /// **'Rideegama'**
  String get rideegama;

  /// No description provided for @udubaddawa.
  ///
  /// In en, this message translates to:
  /// **'Udubaddawa'**
  String get udubaddawa;

  /// No description provided for @wariyapola.
  ///
  /// In en, this message translates to:
  /// **'Wariyapola'**
  String get wariyapola;

  /// No description provided for @weerambugedara.
  ///
  /// In en, this message translates to:
  /// **'Weerambugedara'**
  String get weerambugedara;

  /// No description provided for @anamaduwa.
  ///
  /// In en, this message translates to:
  /// **'Anamaduwa'**
  String get anamaduwa;

  /// No description provided for @arachchikattuwa.
  ///
  /// In en, this message translates to:
  /// **'Arachchikattuwa'**
  String get arachchikattuwa;

  /// No description provided for @chilaw.
  ///
  /// In en, this message translates to:
  /// **'Chilaw'**
  String get chilaw;

  /// No description provided for @dankotuwa.
  ///
  /// In en, this message translates to:
  /// **'Dankotuwa'**
  String get dankotuwa;

  /// No description provided for @kalpitiya.
  ///
  /// In en, this message translates to:
  /// **'Kalpitiya'**
  String get kalpitiya;

  /// No description provided for @karuwalagaswewa.
  ///
  /// In en, this message translates to:
  /// **'Karuwalagaswewa'**
  String get karuwalagaswewa;

  /// No description provided for @madampe.
  ///
  /// In en, this message translates to:
  /// **'Madampe'**
  String get madampe;

  /// No description provided for @mahakumbukkadawala.
  ///
  /// In en, this message translates to:
  /// **'Mahakumbukkadawala'**
  String get mahakumbukkadawala;

  /// No description provided for @mahawewa.
  ///
  /// In en, this message translates to:
  /// **'Mahawewa'**
  String get mahawewa;

  /// No description provided for @mundalama.
  ///
  /// In en, this message translates to:
  /// **'Mundalama'**
  String get mundalama;

  /// No description provided for @nattandiya.
  ///
  /// In en, this message translates to:
  /// **'Nattandiya'**
  String get nattandiya;

  /// No description provided for @nawagattegama.
  ///
  /// In en, this message translates to:
  /// **'Nawagattegama'**
  String get nawagattegama;

  /// No description provided for @pallama.
  ///
  /// In en, this message translates to:
  /// **'Pallama'**
  String get pallama;

  /// No description provided for @vanathavilluwa.
  ///
  /// In en, this message translates to:
  /// **'Vanathavilluwa'**
  String get vanathavilluwa;

  /// No description provided for @wennappuwa.
  ///
  /// In en, this message translates to:
  /// **'Wennappuwa'**
  String get wennappuwa;

  /// No description provided for @aranayaka.
  ///
  /// In en, this message translates to:
  /// **'Aranayaka'**
  String get aranayaka;

  /// No description provided for @bulathkohupitiya.
  ///
  /// In en, this message translates to:
  /// **'Bulathkohupitiya'**
  String get bulathkohupitiya;

  /// No description provided for @dehiovita.
  ///
  /// In en, this message translates to:
  /// **'Dehiovita'**
  String get dehiovita;

  /// No description provided for @deraniyagala.
  ///
  /// In en, this message translates to:
  /// **'Deraniyagala'**
  String get deraniyagala;

  /// No description provided for @galigamuwa.
  ///
  /// In en, this message translates to:
  /// **'Galigamuwa'**
  String get galigamuwa;

  /// No description provided for @mawanella.
  ///
  /// In en, this message translates to:
  /// **'Mawanella'**
  String get mawanella;

  /// No description provided for @rambukkana.
  ///
  /// In en, this message translates to:
  /// **'Rambukkana'**
  String get rambukkana;

  /// No description provided for @ruwanwella.
  ///
  /// In en, this message translates to:
  /// **'Ruwanwella'**
  String get ruwanwella;

  /// No description provided for @warakapola.
  ///
  /// In en, this message translates to:
  /// **'Warakapola'**
  String get warakapola;

  /// No description provided for @yatiyanthota.
  ///
  /// In en, this message translates to:
  /// **'Yatiyanthota'**
  String get yatiyanthota;

  /// No description provided for @ayagama.
  ///
  /// In en, this message translates to:
  /// **'Ayagama'**
  String get ayagama;

  /// No description provided for @balangoda.
  ///
  /// In en, this message translates to:
  /// **'Balangoda'**
  String get balangoda;

  /// No description provided for @eheliyagoda.
  ///
  /// In en, this message translates to:
  /// **'Eheliyagoda'**
  String get eheliyagoda;

  /// No description provided for @elapattha.
  ///
  /// In en, this message translates to:
  /// **'Elapattha'**
  String get elapattha;

  /// No description provided for @embilipitiya.
  ///
  /// In en, this message translates to:
  /// **'Embilipitiya'**
  String get embilipitiya;

  /// No description provided for @godakawela.
  ///
  /// In en, this message translates to:
  /// **'Godakawela'**
  String get godakawela;

  /// No description provided for @imbulpe.
  ///
  /// In en, this message translates to:
  /// **'Imbulpe'**
  String get imbulpe;

  /// No description provided for @kahawatta.
  ///
  /// In en, this message translates to:
  /// **'Kahawatta'**
  String get kahawatta;

  /// No description provided for @kalawana.
  ///
  /// In en, this message translates to:
  /// **'Kalawana'**
  String get kalawana;

  /// No description provided for @kiriella.
  ///
  /// In en, this message translates to:
  /// **'Kiriella'**
  String get kiriella;

  /// No description provided for @kolonna.
  ///
  /// In en, this message translates to:
  /// **'Kolonna'**
  String get kolonna;

  /// No description provided for @kuruvita.
  ///
  /// In en, this message translates to:
  /// **'Kuruvita'**
  String get kuruvita;

  /// No description provided for @nivithigala.
  ///
  /// In en, this message translates to:
  /// **'Nivithigala'**
  String get nivithigala;

  /// No description provided for @opanayaka.
  ///
  /// In en, this message translates to:
  /// **'Opanayaka'**
  String get opanayaka;

  /// No description provided for @pelmadulla.
  ///
  /// In en, this message translates to:
  /// **'Pelmadulla'**
  String get pelmadulla;

  /// No description provided for @weligepola.
  ///
  /// In en, this message translates to:
  /// **'Weligepola'**
  String get weligepola;

  /// No description provided for @akmeemana.
  ///
  /// In en, this message translates to:
  /// **'Akmeemana'**
  String get akmeemana;

  /// No description provided for @ambalangoda.
  ///
  /// In en, this message translates to:
  /// **'Ambalangoda'**
  String get ambalangoda;

  /// No description provided for @baddegama.
  ///
  /// In en, this message translates to:
  /// **'Baddegama'**
  String get baddegama;

  /// No description provided for @balapitiya.
  ///
  /// In en, this message translates to:
  /// **'Balapitiya'**
  String get balapitiya;

  /// No description provided for @benthota.
  ///
  /// In en, this message translates to:
  /// **'Benthota'**
  String get benthota;

  /// No description provided for @bopepoddala.
  ///
  /// In en, this message translates to:
  /// **'Bope-Poddala'**
  String get bopepoddala;

  /// No description provided for @elpitiya.
  ///
  /// In en, this message translates to:
  /// **'Elpitiya'**
  String get elpitiya;

  /// No description provided for @gonapinuwala.
  ///
  /// In en, this message translates to:
  /// **'Gonapinuwala'**
  String get gonapinuwala;

  /// No description provided for @habaraduwa.
  ///
  /// In en, this message translates to:
  /// **'Habaraduwa'**
  String get habaraduwa;

  /// No description provided for @hikkaduwa.
  ///
  /// In en, this message translates to:
  /// **'Hikkaduwa'**
  String get hikkaduwa;

  /// No description provided for @imaduwa.
  ///
  /// In en, this message translates to:
  /// **'Imaduwa'**
  String get imaduwa;

  /// No description provided for @karandeniya.
  ///
  /// In en, this message translates to:
  /// **'Karandeniya'**
  String get karandeniya;

  /// No description provided for @nagoda.
  ///
  /// In en, this message translates to:
  /// **'Nagoda'**
  String get nagoda;

  /// No description provided for @neluwa.
  ///
  /// In en, this message translates to:
  /// **'Neluwa'**
  String get neluwa;

  /// No description provided for @niyagama.
  ///
  /// In en, this message translates to:
  /// **'Niyagama'**
  String get niyagama;

  /// No description provided for @thawalama.
  ///
  /// In en, this message translates to:
  /// **'Thawalama'**
  String get thawalama;

  /// No description provided for @welivitiyadivithura.
  ///
  /// In en, this message translates to:
  /// **'Welivitiya-Divithura'**
  String get welivitiyadivithura;

  /// No description provided for @yakkalamulla.
  ///
  /// In en, this message translates to:
  /// **'Yakkalamulla'**
  String get yakkalamulla;

  /// No description provided for @ambalantota.
  ///
  /// In en, this message translates to:
  /// **'Ambalantota'**
  String get ambalantota;

  /// No description provided for @angunakolapelessa.
  ///
  /// In en, this message translates to:
  /// **'Angunakolapelessa'**
  String get angunakolapelessa;

  /// No description provided for @beliatta.
  ///
  /// In en, this message translates to:
  /// **'Beliatta'**
  String get beliatta;

  /// No description provided for @katuwana.
  ///
  /// In en, this message translates to:
  /// **'Katuwana'**
  String get katuwana;

  /// No description provided for @lunugamvehera.
  ///
  /// In en, this message translates to:
  /// **'Lunugamvehera'**
  String get lunugamvehera;

  /// No description provided for @okewela.
  ///
  /// In en, this message translates to:
  /// **'Okewela'**
  String get okewela;

  /// No description provided for @sooriyawewa.
  ///
  /// In en, this message translates to:
  /// **'Sooriyawewa'**
  String get sooriyawewa;

  /// No description provided for @tangalle.
  ///
  /// In en, this message translates to:
  /// **'Tangalle'**
  String get tangalle;

  /// No description provided for @thissamaharama.
  ///
  /// In en, this message translates to:
  /// **'Thissamaharama'**
  String get thissamaharama;

  /// No description provided for @walasmulla.
  ///
  /// In en, this message translates to:
  /// **'Walasmulla'**
  String get walasmulla;

  /// No description provided for @weeraketiya.
  ///
  /// In en, this message translates to:
  /// **'Weeraketiya'**
  String get weeraketiya;

  /// No description provided for @akuressa.
  ///
  /// In en, this message translates to:
  /// **'Akuressa'**
  String get akuressa;

  /// No description provided for @athuraliya.
  ///
  /// In en, this message translates to:
  /// **'Athuraliya'**
  String get athuraliya;

  /// No description provided for @devinuwara.
  ///
  /// In en, this message translates to:
  /// **'Devinuwara'**
  String get devinuwara;

  /// No description provided for @dickwella.
  ///
  /// In en, this message translates to:
  /// **'Dickwella'**
  String get dickwella;

  /// No description provided for @hakmana.
  ///
  /// In en, this message translates to:
  /// **'Hakmana'**
  String get hakmana;

  /// No description provided for @kamburupitiya.
  ///
  /// In en, this message translates to:
  /// **'Kamburupitiya'**
  String get kamburupitiya;

  /// No description provided for @kirindapuhulwella.
  ///
  /// In en, this message translates to:
  /// **'Kirinda Puhulwella'**
  String get kirindapuhulwella;

  /// No description provided for @kotapola.
  ///
  /// In en, this message translates to:
  /// **'Kotapola'**
  String get kotapola;

  /// No description provided for @malimbada.
  ///
  /// In en, this message translates to:
  /// **'Malimbada'**
  String get malimbada;

  /// No description provided for @mulatiyana.
  ///
  /// In en, this message translates to:
  /// **'Mulatiyana'**
  String get mulatiyana;

  /// No description provided for @pasgoda.
  ///
  /// In en, this message translates to:
  /// **'Pasgoda'**
  String get pasgoda;

  /// No description provided for @pitabeddara.
  ///
  /// In en, this message translates to:
  /// **'Pitabeddara'**
  String get pitabeddara;

  /// No description provided for @thihagoda.
  ///
  /// In en, this message translates to:
  /// **'Thihagoda'**
  String get thihagoda;

  /// No description provided for @weligama.
  ///
  /// In en, this message translates to:
  /// **'Weligama'**
  String get weligama;

  /// No description provided for @welipitiya.
  ///
  /// In en, this message translates to:
  /// **'Welipitiya'**
  String get welipitiya;

  /// No description provided for @bandarawela.
  ///
  /// In en, this message translates to:
  /// **'Bandarawela'**
  String get bandarawela;

  /// No description provided for @ella.
  ///
  /// In en, this message translates to:
  /// **'Ella'**
  String get ella;

  /// No description provided for @haldummulla.
  ///
  /// In en, this message translates to:
  /// **'Haldummulla'**
  String get haldummulla;

  /// No description provided for @haliela.
  ///
  /// In en, this message translates to:
  /// **'Hali-Ela'**
  String get haliela;

  /// No description provided for @haputale.
  ///
  /// In en, this message translates to:
  /// **'Haputale'**
  String get haputale;

  /// No description provided for @kandaketiya.
  ///
  /// In en, this message translates to:
  /// **'Kandaketiya'**
  String get kandaketiya;

  /// No description provided for @lunugala.
  ///
  /// In en, this message translates to:
  /// **'Lunugala'**
  String get lunugala;

  /// No description provided for @mahiyanganaya.
  ///
  /// In en, this message translates to:
  /// **'Mahiyanganaya'**
  String get mahiyanganaya;

  /// No description provided for @meegahakivula.
  ///
  /// In en, this message translates to:
  /// **'Meegahakivula'**
  String get meegahakivula;

  /// No description provided for @passara.
  ///
  /// In en, this message translates to:
  /// **'Passara'**
  String get passara;

  /// No description provided for @rideemaliyadda.
  ///
  /// In en, this message translates to:
  /// **'Rideemaliyadda'**
  String get rideemaliyadda;

  /// No description provided for @soranathota.
  ///
  /// In en, this message translates to:
  /// **'Soranathota'**
  String get soranathota;

  /// No description provided for @uvaparanagama.
  ///
  /// In en, this message translates to:
  /// **'Uva-Paranagama'**
  String get uvaparanagama;

  /// No description provided for @welimada.
  ///
  /// In en, this message translates to:
  /// **'Welimada'**
  String get welimada;

  /// No description provided for @badalkumbura.
  ///
  /// In en, this message translates to:
  /// **'Badalkumbura'**
  String get badalkumbura;

  /// No description provided for @bibile.
  ///
  /// In en, this message translates to:
  /// **'Bibile'**
  String get bibile;

  /// No description provided for @buttala.
  ///
  /// In en, this message translates to:
  /// **'Buttala'**
  String get buttala;

  /// No description provided for @katharagama.
  ///
  /// In en, this message translates to:
  /// **'Katharagama'**
  String get katharagama;

  /// No description provided for @madulla.
  ///
  /// In en, this message translates to:
  /// **'Madulla'**
  String get madulla;

  /// No description provided for @medagama.
  ///
  /// In en, this message translates to:
  /// **'Medagama'**
  String get medagama;

  /// No description provided for @moneragala.
  ///
  /// In en, this message translates to:
  /// **'Moneragala'**
  String get moneragala;

  /// No description provided for @sevanagala.
  ///
  /// In en, this message translates to:
  /// **'Sevanagala'**
  String get sevanagala;

  /// No description provided for @siyambalanduwa.
  ///
  /// In en, this message translates to:
  /// **'Siyambalanduwa'**
  String get siyambalanduwa;

  /// No description provided for @thanamalvila.
  ///
  /// In en, this message translates to:
  /// **'Thanamalvila'**
  String get thanamalvila;

  /// No description provided for @wellawaya.
  ///
  /// In en, this message translates to:
  /// **'Wellawaya'**
  String get wellawaya;

  /// No description provided for @dehiwala.
  ///
  /// In en, this message translates to:
  /// **'Dehiwala (15)'**
  String get dehiwala;

  /// No description provided for @homagama.
  ///
  /// In en, this message translates to:
  /// **'Homagama (81)'**
  String get homagama;

  /// No description provided for @kaduwela.
  ///
  /// In en, this message translates to:
  /// **'Kaduwela (57)'**
  String get kaduwela;

  /// No description provided for @kesbewa.
  ///
  /// In en, this message translates to:
  /// **'Kesbewa (73)'**
  String get kesbewa;

  /// No description provided for @kolonnawa.
  ///
  /// In en, this message translates to:
  /// **'Kolonnawa (46)'**
  String get kolonnawa;

  /// No description provided for @kotte.
  ///
  /// In en, this message translates to:
  /// **'Kotte (20)'**
  String get kotte;

  /// No description provided for @maharagama.
  ///
  /// In en, this message translates to:
  /// **'Maharagama (41)'**
  String get maharagama;

  /// No description provided for @moratuwa.
  ///
  /// In en, this message translates to:
  /// **'Moratuwa (42)'**
  String get moratuwa;

  /// No description provided for @padukka.
  ///
  /// In en, this message translates to:
  /// **'Padukka (46)'**
  String get padukka;

  /// No description provided for @ratmalana.
  ///
  /// In en, this message translates to:
  /// **'Ratmalana (13)'**
  String get ratmalana;

  /// No description provided for @seethawaka.
  ///
  /// In en, this message translates to:
  /// **'Seethawaka (68)'**
  String get seethawaka;

  /// No description provided for @thimbirigasyaya.
  ///
  /// In en, this message translates to:
  /// **'Thimbirigasyaya (29)'**
  String get thimbirigasyaya;

  /// No description provided for @attanagalla.
  ///
  /// In en, this message translates to:
  /// **'Attanagalla'**
  String get attanagalla;

  /// No description provided for @biyagama.
  ///
  /// In en, this message translates to:
  /// **'Biyagama'**
  String get biyagama;

  /// No description provided for @divulapitiya.
  ///
  /// In en, this message translates to:
  /// **'Divulapitiya'**
  String get divulapitiya;

  /// No description provided for @dompe.
  ///
  /// In en, this message translates to:
  /// **'Dompe'**
  String get dompe;

  /// No description provided for @jaela.
  ///
  /// In en, this message translates to:
  /// **'Ja-Ela'**
  String get jaela;

  /// No description provided for @katana.
  ///
  /// In en, this message translates to:
  /// **'Katana'**
  String get katana;

  /// No description provided for @kelaniya.
  ///
  /// In en, this message translates to:
  /// **'Kelaniya'**
  String get kelaniya;

  /// No description provided for @mahara.
  ///
  /// In en, this message translates to:
  /// **'Mahara'**
  String get mahara;

  /// No description provided for @minuwangoda.
  ///
  /// In en, this message translates to:
  /// **'Minuwangoda'**
  String get minuwangoda;

  /// No description provided for @mirigama.
  ///
  /// In en, this message translates to:
  /// **'Mirigama'**
  String get mirigama;

  /// No description provided for @negombo.
  ///
  /// In en, this message translates to:
  /// **'Negombo'**
  String get negombo;

  /// No description provided for @wattala.
  ///
  /// In en, this message translates to:
  /// **'Wattala'**
  String get wattala;

  /// No description provided for @agalawatta.
  ///
  /// In en, this message translates to:
  /// **'Agalawatta'**
  String get agalawatta;

  /// No description provided for @bandaragama.
  ///
  /// In en, this message translates to:
  /// **'Bandaragama'**
  String get bandaragama;

  /// No description provided for @beruwala.
  ///
  /// In en, this message translates to:
  /// **'Beruwala'**
  String get beruwala;

  /// No description provided for @bulathsinhala.
  ///
  /// In en, this message translates to:
  /// **'Bulathsinhala'**
  String get bulathsinhala;

  /// No description provided for @dodangoda.
  ///
  /// In en, this message translates to:
  /// **'Dodangoda'**
  String get dodangoda;

  /// No description provided for @horana.
  ///
  /// In en, this message translates to:
  /// **'Horana'**
  String get horana;

  /// No description provided for @ingiriya.
  ///
  /// In en, this message translates to:
  /// **'Ingiriya'**
  String get ingiriya;

  /// No description provided for @madurawela.
  ///
  /// In en, this message translates to:
  /// **'Madurawela'**
  String get madurawela;

  /// No description provided for @mathugama.
  ///
  /// In en, this message translates to:
  /// **'Mathugama'**
  String get mathugama;

  /// No description provided for @millaniya.
  ///
  /// In en, this message translates to:
  /// **'Millaniya'**
  String get millaniya;

  /// No description provided for @palindanuwara.
  ///
  /// In en, this message translates to:
  /// **'Palindanuwara'**
  String get palindanuwara;

  /// No description provided for @panadura.
  ///
  /// In en, this message translates to:
  /// **'Panadura'**
  String get panadura;

  /// No description provided for @walallavita.
  ///
  /// In en, this message translates to:
  /// **'Walallavita'**
  String get walallavita;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @mainName.
  ///
  /// In en, this message translates to:
  /// **'Main Name'**
  String get mainName;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category  Name'**
  String get categoryName;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @userInputs.
  ///
  /// In en, this message translates to:
  /// **'User Inputs'**
  String get userInputs;

  /// No description provided for @userSelection.
  ///
  /// In en, this message translates to:
  /// **'User Selection'**
  String get userSelection;

  /// No description provided for @rs.
  ///
  /// In en, this message translates to:
  /// **'Rs:'**
  String get rs;

  /// No description provided for @rentTabName1.
  ///
  /// In en, this message translates to:
  /// **'Lease Sale'**
  String get rentTabName1;

  /// No description provided for @rentTabName2.
  ///
  /// In en, this message translates to:
  /// **'Lease Purchase'**
  String get rentTabName2;

  /// No description provided for @labourTabName1.
  ///
  /// In en, this message translates to:
  /// **'Giving'**
  String get labourTabName1;

  /// No description provided for @labourTabName2.
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get labourTabName2;

  /// No description provided for @paddyInstitue.
  ///
  /// In en, this message translates to:
  /// **'Research Institute'**
  String get paddyInstitue;

  /// No description provided for @paddyGenre.
  ///
  /// In en, this message translates to:
  /// **'Varieties'**
  String get paddyGenre;

  /// No description provided for @main_instruct.
  ///
  /// In en, this message translates to:
  /// **'Select what you need'**
  String get main_instruct;

  /// No description provided for @createaccount.
  ///
  /// In en, this message translates to:
  /// **'Create a Account'**
  String get createaccount;

  /// No description provided for @selectPreferredMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred sign up method'**
  String get selectPreferredMethod;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'userName'**
  String get userName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @alreadyhave.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyhave;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @eggprice.
  ///
  /// In en, this message translates to:
  /// **'An Egg Price'**
  String get eggprice;

  /// No description provided for @hinteggprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of an egg'**
  String get hinteggprice;

  /// No description provided for @colonyprice.
  ///
  /// In en, this message translates to:
  /// **'The price of a colony'**
  String get colonyprice;

  /// No description provided for @colonyquantity.
  ///
  /// In en, this message translates to:
  /// **'Colony Quantity'**
  String get colonyquantity;

  /// No description provided for @honeybottlesprice.
  ///
  /// In en, this message translates to:
  /// **'Honney bottles price'**
  String get honeybottlesprice;

  /// No description provided for @honeybottlesquantity.
  ///
  /// In en, this message translates to:
  /// **'Honey bottles quantity'**
  String get honeybottlesquantity;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aswenna'**
  String get welcomeText;

  /// No description provided for @marketPlace.
  ///
  /// In en, this message translates to:
  /// **'Your Agriculture  MarketPlace'**
  String get marketPlace;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @animalquantity.
  ///
  /// In en, this message translates to:
  /// **'Enter number of animals'**
  String get animalquantity;

  /// No description provided for @animalprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a animal'**
  String get animalprice;

  /// No description provided for @numberofliters.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of liters'**
  String get numberofliters;

  /// No description provided for @priceforaliter.
  ///
  /// In en, this message translates to:
  /// **'Enter the price for a liter'**
  String get priceforaliter;

  /// No description provided for @lifeweight.
  ///
  /// In en, this message translates to:
  /// **'Live weight of a animal'**
  String get lifeweight;

  /// No description provided for @priceofbushal.
  ///
  /// In en, this message translates to:
  /// **'Price of a Busal'**
  String get priceofbushal;

  /// No description provided for @numberofbushal.
  ///
  /// In en, this message translates to:
  /// **'No. of Busal'**
  String get numberofbushal;

  /// No description provided for @amountofseedsinapacket.
  ///
  /// In en, this message translates to:
  /// **'Amount of seeds in a packet'**
  String get amountofseedsinapacket;

  /// No description provided for @hintamountofseedsinapacket.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount of seeds in the packet.'**
  String get hintamountofseedsinapacket;

  /// No description provided for @numberofpackets.
  ///
  /// In en, this message translates to:
  /// **'Number of packets'**
  String get numberofpackets;

  /// No description provided for @hintnumberofpackets.
  ///
  /// In en, this message translates to:
  /// **'EnterNumber of packets'**
  String get hintnumberofpackets;

  /// No description provided for @priceforapack.
  ///
  /// In en, this message translates to:
  /// **'Price for a packet'**
  String get priceforapack;

  /// No description provided for @priceofanut.
  ///
  /// In en, this message translates to:
  /// **'Price of a nut'**
  String get priceofanut;

  /// No description provided for @noofnuts.
  ///
  /// In en, this message translates to:
  /// **'No of Nuts'**
  String get noofnuts;

  /// No description provided for @priceof1kgofseeds.
  ///
  /// In en, this message translates to:
  /// **'Price of 1kg of Seeds'**
  String get priceof1kgofseeds;

  /// No description provided for @numberofseedkg.
  ///
  /// In en, this message translates to:
  /// **'Number of seeds kg'**
  String get numberofseedkg;

  /// No description provided for @hintpriceof1kgofseeds.
  ///
  /// In en, this message translates to:
  /// **'Enter the price of 1 kg of seeds'**
  String get hintpriceof1kgofseeds;

  /// No description provided for @hintnumberofseedkg.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of kg of seeds'**
  String get hintnumberofseedkg;

  /// No description provided for @priceofaplant.
  ///
  /// In en, this message translates to:
  /// **'Price of a Plant'**
  String get priceofaplant;

  /// No description provided for @numberofplants.
  ///
  /// In en, this message translates to:
  /// **'Number of plants'**
  String get numberofplants;

  /// No description provided for @priceofawirerool.
  ///
  /// In en, this message translates to:
  /// **'Price of a wire roll'**
  String get priceofawirerool;

  /// No description provided for @lengthofaroll.
  ///
  /// In en, this message translates to:
  /// **'Length of a roll'**
  String get lengthofaroll;

  /// No description provided for @weightofaroll.
  ///
  /// In en, this message translates to:
  /// **'Weight of a roll'**
  String get weightofaroll;

  /// No description provided for @numberofrolls.
  ///
  /// In en, this message translates to:
  /// **'Number of rolls'**
  String get numberofrolls;

  /// No description provided for @lengthofapipe.
  ///
  /// In en, this message translates to:
  /// **'Length of a pipe'**
  String get lengthofapipe;

  /// No description provided for @diameterofapipe.
  ///
  /// In en, this message translates to:
  /// **'Diameter of a pipe'**
  String get diameterofapipe;

  /// No description provided for @thicknessofapipe.
  ///
  /// In en, this message translates to:
  /// **'Thickness of a pipe'**
  String get thicknessofapipe;

  /// No description provided for @weightofapipe.
  ///
  /// In en, this message translates to:
  /// **'Weight of a pipe'**
  String get weightofapipe;

  /// No description provided for @numberofpipe.
  ///
  /// In en, this message translates to:
  /// **'Number of pipe'**
  String get numberofpipe;

  /// No description provided for @highofamesh.
  ///
  /// In en, this message translates to:
  /// **'Height of the Mesh'**
  String get highofamesh;

  /// No description provided for @priceofaroll.
  ///
  /// In en, this message translates to:
  /// **'Price of a roll'**
  String get priceofaroll;

  /// No description provided for @thickness.
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get thickness;

  /// No description provided for @hintKg.
  ///
  /// In en, this message translates to:
  /// **'Enter weight in kg'**
  String get hintKg;

  /// No description provided for @hintkgPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a kg'**
  String get hintkgPrice;

  /// No description provided for @hintarcs.
  ///
  /// In en, this message translates to:
  /// **'Enter acres quantity'**
  String get hintarcs;

  /// No description provided for @hintperches.
  ///
  /// In en, this message translates to:
  /// **'Enter perches quantity'**
  String get hintperches;

  /// No description provided for @hintlandPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter the price for the total land'**
  String get hintlandPrice;

  /// No description provided for @hintquantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get hintquantity;

  /// No description provided for @hintunitprice.
  ///
  /// In en, this message translates to:
  /// **'Enter unit price'**
  String get hintunitprice;

  /// No description provided for @hintcolony.
  ///
  /// In en, this message translates to:
  /// **'Enter colony quantity'**
  String get hintcolony;

  /// No description provided for @hintcolonyprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a colony'**
  String get hintcolonyprice;

  /// No description provided for @hinthoneybottlequantity.
  ///
  /// In en, this message translates to:
  /// **'Enter honey bottles quantity'**
  String get hinthoneybottlequantity;

  /// No description provided for @hintpriceofahoneybottle.
  ///
  /// In en, this message translates to:
  /// **'Enter the price of a honey bottle'**
  String get hintpriceofahoneybottle;

  /// No description provided for @hintliters.
  ///
  /// In en, this message translates to:
  /// **'Enter number of liters'**
  String get hintliters;

  /// No description provided for @hintliterprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a liter'**
  String get hintliterprice;

  /// No description provided for @hintliveweight.
  ///
  /// In en, this message translates to:
  /// **'Enter the live weight of an animal.'**
  String get hintliveweight;

  /// No description provided for @hintanimalquantity.
  ///
  /// In en, this message translates to:
  /// **'Enter the quantity of animals'**
  String get hintanimalquantity;

  /// No description provided for @hintpriceofaanimal.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a animal'**
  String get hintpriceofaanimal;

  /// No description provided for @hintbusal.
  ///
  /// In en, this message translates to:
  /// **'Enter the Busal quantity'**
  String get hintbusal;

  /// No description provided for @hintbusalprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a Busal'**
  String get hintbusalprice;

  /// No description provided for @hintpriceofaroll.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a roll'**
  String get hintpriceofaroll;

  /// No description provided for @hintlengthofaroll.
  ///
  /// In en, this message translates to:
  /// **'Enter length of a roll'**
  String get hintlengthofaroll;

  /// No description provided for @hintweightofaroll.
  ///
  /// In en, this message translates to:
  /// **'Enter weight of a roll'**
  String get hintweightofaroll;

  /// No description provided for @hintnumberofrolls.
  ///
  /// In en, this message translates to:
  /// **'Enter number of rolls'**
  String get hintnumberofrolls;

  /// No description provided for @hintpipelength.
  ///
  /// In en, this message translates to:
  /// **'Enter Length of a pipe'**
  String get hintpipelength;

  /// No description provided for @hintdiameter.
  ///
  /// In en, this message translates to:
  /// **'Enter Diameter of a pipe'**
  String get hintdiameter;

  /// No description provided for @hintpipeweight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight of a pipe'**
  String get hintpipeweight;

  /// No description provided for @hintnumberofpipes.
  ///
  /// In en, this message translates to:
  /// **'Enter number of a pipes'**
  String get hintnumberofpipes;

  /// No description provided for @hintpipeprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a pipe'**
  String get hintpipeprice;

  /// No description provided for @hintheightofamesh.
  ///
  /// In en, this message translates to:
  /// **'Enter height of a mesh'**
  String get hintheightofamesh;

  /// No description provided for @heightofaroll.
  ///
  /// In en, this message translates to:
  /// **'Height of a roll'**
  String get heightofaroll;

  /// No description provided for @hinthightofaroll.
  ///
  /// In en, this message translates to:
  /// **'Enter height of a roll'**
  String get hinthightofaroll;

  /// No description provided for @hintthickness.
  ///
  /// In en, this message translates to:
  /// **'Enter the thickness'**
  String get hintthickness;

  /// No description provided for @packet.
  ///
  /// In en, this message translates to:
  /// **'Number of packets'**
  String get packet;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Number of pieces in a packet'**
  String get pieces;

  /// No description provided for @packetprice.
  ///
  /// In en, this message translates to:
  /// **'Price of a packet'**
  String get packetprice;

  /// No description provided for @hintpacket.
  ///
  /// In en, this message translates to:
  /// **'Enter number of packets'**
  String get hintpacket;

  /// No description provided for @hintprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a packet'**
  String get hintprice;

  /// No description provided for @hintpricefor1kg.
  ///
  /// In en, this message translates to:
  /// **'Enter price for one KG'**
  String get hintpricefor1kg;

  /// No description provided for @hintpieces.
  ///
  /// In en, this message translates to:
  /// **'Enter number of pieces in a packet'**
  String get hintpieces;

  /// No description provided for @instructionPara1.
  ///
  /// In en, this message translates to:
  /// **'On the main page, you’ll see several options — use them to navigate to the section you need. This application helps all kinds of farmers find good markets for their products and services. We have properly categorized every product and service to make it easier for you to find what you’re looking for. From any section, you can perform actions such as adding new items, viewing other listings, or checking details of available products and services.'**
  String get instructionPara1;

  /// No description provided for @instructionPara2.
  ///
  /// In en, this message translates to:
  /// **'The app mainly focuses on two things: selling and buying.'**
  String get instructionPara2;

  /// No description provided for @instructionPoint1.
  ///
  /// In en, this message translates to:
  /// **'To sell a product, go to the To Sell section and tap the + button at the bottom-right to add your item.'**
  String get instructionPoint1;

  /// No description provided for @instructionPoint2.
  ///
  /// In en, this message translates to:
  /// **'If you need a product or service but can’t find it in the To Sell section, go to the To Buy section and add your request there. (Images are optional for the To Buy listings.)'**
  String get instructionPoint2;

  /// No description provided for @instructionPara3.
  ///
  /// In en, this message translates to:
  /// **'For the best results, make sure to select your district and Divisional Secretary area when adding a listing.'**
  String get instructionPara3;

  /// No description provided for @itemname.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemname;

  /// No description provided for @hintitemname.
  ///
  /// In en, this message translates to:
  /// **'Enter the item name'**
  String get hintitemname;

  /// No description provided for @plantsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Plants Quantity'**
  String get plantsQuantity;

  /// No description provided for @hintplantsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter the Plants Quantity'**
  String get hintplantsQuantity;

  /// No description provided for @plantPrice.
  ///
  /// In en, this message translates to:
  /// **'Price for a plant'**
  String get plantPrice;

  /// No description provided for @hintPlantPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a plant'**
  String get hintPlantPrice;

  /// No description provided for @planttype.
  ///
  /// In en, this message translates to:
  /// **'Plant type'**
  String get planttype;

  /// No description provided for @hintpalnttype.
  ///
  /// In en, this message translates to:
  /// **'Enter the plant type'**
  String get hintpalnttype;

  /// No description provided for @give.
  ///
  /// In en, this message translates to:
  /// **'To Give'**
  String get give;

  /// No description provided for @need.
  ///
  /// In en, this message translates to:
  /// **'Need'**
  String get need;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @diameter.
  ///
  /// In en, this message translates to:
  /// **'Diameter'**
  String get diameter;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Main Page'**
  String get home;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Added Items'**
  String get listings;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'MAIN'**
  String get main;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about_app;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate US'**
  String get rateUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @vehicletype.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicletype;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Manufactured Year'**
  String get year;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing company'**
  String get manufacturer;

  /// No description provided for @noOfOwners.
  ///
  /// In en, this message translates to:
  /// **'Number of Owners'**
  String get noOfOwners;

  /// No description provided for @vehicleprice.
  ///
  /// In en, this message translates to:
  /// **'Price of a Vehicle'**
  String get vehicleprice;

  /// No description provided for @hintType.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Type'**
  String get hintType;

  /// No description provided for @hintyear.
  ///
  /// In en, this message translates to:
  /// **'Enter the Year'**
  String get hintyear;

  /// No description provided for @hintmanufacturer.
  ///
  /// In en, this message translates to:
  /// **'Enter the Manufacturer'**
  String get hintmanufacturer;

  /// No description provided for @hintnoofowners.
  ///
  /// In en, this message translates to:
  /// **'Enter Number of Owners'**
  String get hintnoofowners;

  /// No description provided for @hintvehicleprice.
  ///
  /// In en, this message translates to:
  /// **'Enter the price of a vehicle'**
  String get hintvehicleprice;

  /// No description provided for @countnuts.
  ///
  /// In en, this message translates to:
  /// **'No of Nuts'**
  String get countnuts;

  /// No description provided for @hintnunts.
  ///
  /// In en, this message translates to:
  /// **'Enter No of nut'**
  String get hintnunts;

  /// No description provided for @hintnuntsprice.
  ///
  /// In en, this message translates to:
  /// **'Enter the Price of a nut'**
  String get hintnuntsprice;

  /// No description provided for @numberofhusks.
  ///
  /// In en, this message translates to:
  /// **'Number of husks'**
  String get numberofhusks;

  /// No description provided for @priceofhusk.
  ///
  /// In en, this message translates to:
  /// **'Price of a Husk'**
  String get priceofhusk;

  /// No description provided for @hintnumberofhusk.
  ///
  /// In en, this message translates to:
  /// **'Enter number of husks'**
  String get hintnumberofhusk;

  /// No description provided for @hintpriceofahusk.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a Husk'**
  String get hintpriceofahusk;

  /// No description provided for @numberoffronds.
  ///
  /// In en, this message translates to:
  /// **'Number of coconut Fronds'**
  String get numberoffronds;

  /// No description provided for @hintfronds.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of coconut Fronds'**
  String get hintfronds;

  /// No description provided for @pricefrond.
  ///
  /// In en, this message translates to:
  /// **'Price of a coconut Frond'**
  String get pricefrond;

  /// No description provided for @hintpricefrond.
  ///
  /// In en, this message translates to:
  /// **'Enter the price of a coconut Frond.'**
  String get hintpricefrond;

  /// No description provided for @bundleprice.
  ///
  /// In en, this message translates to:
  /// **'Price of a Bag'**
  String get bundleprice;

  /// No description provided for @hintpricebundle.
  ///
  /// In en, this message translates to:
  /// **'Enter the Price of a bag'**
  String get hintpricebundle;

  /// No description provided for @hintnumberofbundles.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of bags'**
  String get hintnumberofbundles;

  /// No description provided for @numberofbundles.
  ///
  /// In en, this message translates to:
  /// **'Number of bags'**
  String get numberofbundles;

  /// No description provided for @betelquantity.
  ///
  /// In en, this message translates to:
  /// **'Number of betel leaves'**
  String get betelquantity;

  /// No description provided for @hintbetelquantity.
  ///
  /// In en, this message translates to:
  /// **'Enter number of betel leaves'**
  String get hintbetelquantity;

  /// No description provided for @priceofbetel.
  ///
  /// In en, this message translates to:
  /// **'Price of 1000 leaves'**
  String get priceofbetel;

  /// No description provided for @hintpricebetel.
  ///
  /// In en, this message translates to:
  /// **'Enter the price for the 1000 leaves'**
  String get hintpricebetel;

  /// No description provided for @stickprice.
  ///
  /// In en, this message translates to:
  /// **'Price of a stick'**
  String get stickprice;

  /// No description provided for @hintstickPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a stick'**
  String get hintstickPrice;

  /// No description provided for @noofsticks.
  ///
  /// In en, this message translates to:
  /// **'Number of sticks'**
  String get noofsticks;

  /// No description provided for @hintsticks.
  ///
  /// In en, this message translates to:
  /// **'Enter number of sticks'**
  String get hintsticks;

  /// No description provided for @priceroot.
  ///
  /// In en, this message translates to:
  /// **'Price of a root pieces'**
  String get priceroot;

  /// No description provided for @hitnpricerrot.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a root pieces'**
  String get hitnpricerrot;

  /// No description provided for @priceshoots.
  ///
  /// In en, this message translates to:
  /// **'Price of a shoots'**
  String get priceshoots;

  /// No description provided for @hintshoots.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a shoots'**
  String get hintshoots;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Your age'**
  String get age;

  /// No description provided for @hintage.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get hintage;

  /// No description provided for @hintseedpacket.
  ///
  /// In en, this message translates to:
  /// **'The amount of seeds in a packet'**
  String get hintseedpacket;

  /// No description provided for @fertilizerbags.
  ///
  /// In en, this message translates to:
  /// **'Number of fertilizer bags'**
  String get fertilizerbags;

  /// No description provided for @hintfertlizerbags.
  ///
  /// In en, this message translates to:
  /// **'Enter number of fertilizer bags'**
  String get hintfertlizerbags;

  /// No description provided for @fertilizerbagsize.
  ///
  /// In en, this message translates to:
  /// **'Size of a fertilizer bag(kg)'**
  String get fertilizerbagsize;

  /// No description provided for @hintfertilizerbagsize.
  ///
  /// In en, this message translates to:
  /// **'Enter size of a fertilizer bag'**
  String get hintfertilizerbagsize;

  /// No description provided for @fertilizerbagprice.
  ///
  /// In en, this message translates to:
  /// **'Price of a fertilizer bag'**
  String get fertilizerbagprice;

  /// No description provided for @hintfertilizerbagprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price of a fertilizer bag'**
  String get hintfertilizerbagprice;

  /// No description provided for @qubic.
  ///
  /// In en, this message translates to:
  /// **'No of Cubic feet'**
  String get qubic;

  /// No description provided for @hintqubic.
  ///
  /// In en, this message translates to:
  /// **'Enter no of cubic feet'**
  String get hintqubic;

  /// No description provided for @qubicprice.
  ///
  /// In en, this message translates to:
  /// **'Price per cubic foot'**
  String get qubicprice;

  /// No description provided for @hintqubicprice.
  ///
  /// In en, this message translates to:
  /// **'Enter price per cubic foot'**
  String get hintqubicprice;

  /// No description provided for @flower.
  ///
  /// In en, this message translates to:
  /// **'Flower Count'**
  String get flower;

  /// No description provided for @hintflower.
  ///
  /// In en, this message translates to:
  /// **'Enter flower count'**
  String get hintflower;

  /// No description provided for @flowerprice.
  ///
  /// In en, this message translates to:
  /// **'Flower price'**
  String get flowerprice;

  /// No description provided for @hintflowerprice.
  ///
  /// In en, this message translates to:
  /// **'Enter flower price'**
  String get hintflowerprice;

  /// No description provided for @calf.
  ///
  /// In en, this message translates to:
  /// **'Calf count'**
  String get calf;

  /// No description provided for @hintcalf.
  ///
  /// In en, this message translates to:
  /// **'Enter calf count'**
  String get hintcalf;

  /// No description provided for @calfprice.
  ///
  /// In en, this message translates to:
  /// **'Calf price'**
  String get calfprice;

  /// No description provided for @hintcalfprice.
  ///
  /// In en, this message translates to:
  /// **'Enter calf price'**
  String get hintcalfprice;

  /// No description provided for @priceforhour.
  ///
  /// In en, this message translates to:
  /// **'Price for a hour'**
  String get priceforhour;

  /// No description provided for @hintpriceforhour.
  ///
  /// In en, this message translates to:
  /// **'Enter price for a hour'**
  String get hintpriceforhour;

  /// No description provided for @servicename.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get servicename;

  /// No description provided for @hintserviceName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the service.'**
  String get hintserviceName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
