import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/auth_service.dart';
import 'package:wallet_flutter/network/giftcards.dart';
import 'package:wallet_flutter/network/metadata_service.dart';
import 'package:wallet_flutter/network/subscription_service.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<AccountService>(() => AccountService());
  sl.registerLazySingleton<UsernameService>(() => UsernameService());
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<MetadataService>(() => MetadataService());
  sl.registerLazySingleton<GiftCards>(() => GiftCards());
  sl.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  sl.registerLazySingleton<DBHelper>(() => DBHelper());
  sl.registerLazySingleton<HapticUtil>(() => HapticUtil());
  sl.registerLazySingleton<BiometricUtil>(() => BiometricUtil());
  sl.registerLazySingleton<Vault>(() => Vault());
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<Logger>(() => Logger(printer: PrettyPrinter()));
}