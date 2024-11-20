import 'package:get_it/get_it.dart';
import 'permission_service.dart';
import 'permisson_handler_permission_service.dart';
import 'package:ess_app/media/media_service_interface.dart';
import 'package:ess_app/media/media_servide.dart';
final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerSingleton<PermissionService>
    (PermissionHandlerPermissionService());
  getIt.registerSingleton<MediaServiceInterface>(MediaService());
}