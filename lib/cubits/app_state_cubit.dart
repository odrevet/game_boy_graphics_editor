import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState(selectedIntensity: 3));
}
