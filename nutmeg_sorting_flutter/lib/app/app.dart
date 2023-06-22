import 'package:ring_sorting_flutter/services/db_service.dart';
import 'package:ring_sorting_flutter/services/image_processing_service.dart';
import 'package:ring_sorting_flutter/services/storage_service.dart';
import 'package:ring_sorting_flutter/ui/views/automatic/automatic_view.dart';
import 'package:ring_sorting_flutter/ui/views/control/control_view.dart';
import 'package:ring_sorting_flutter/ui/views/train/train_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/views/home/home_view.dart';
import '../ui/views/startup/startup_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: HomeView, path: '/home'),
    MaterialRoute(page: ControlView, path: '/control'),
    MaterialRoute(page: AutomaticView, path: '/automatic'),
    MaterialRoute(page: TrainView, path: '/train'),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DbService),
    LazySingleton(classType: ImageProcessingService),
    LazySingleton(classType: StorageService),
  ],
  logger: StackedLogger(),
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
