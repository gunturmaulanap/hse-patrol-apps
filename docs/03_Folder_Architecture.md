# 03 Folder Architecture

## Arsitektur folder yang direkomendasikan
Gunakan **feature-first modular structure**.

## Root structure
```text
lib/
  app/
    app.dart
    router/
      app_router.dart
      route_names.dart
    theme/
      app_colors.dart
      app_text_styles.dart
      app_theme.dart
    config/
      env.dart
      app_constants.dart

  core/
    network/
      api_client.dart
      api_exception.dart
      api_response.dart
      dio_interceptor.dart
    storage/
      secure_storage_service.dart
    permissions/
      camera_permission_service.dart
    utils/
      date_formatter.dart
      validators.dart
      result.dart
    widgets/
      app_button.dart
      app_text_field.dart
      app_card.dart
      app_error_view.dart
      app_empty_view.dart
      app_loading_view.dart
      app_app_bar.dart
      step_progress_header.dart
      photo_slot_card.dart
    services/
      snackbar_service.dart
      dialog_service.dart
    extensions/
      context_extension.dart
      string_extension.dart

  features/
    auth/
      data/
        datasource/
          auth_remote_datasource.dart
        models/
          login_request_model.dart
          login_response_model.dart
          user_model.dart
        repositories/
          auth_repository_impl.dart
      domain/
        entities/
          user_entity.dart
        repositories/
          auth_repository.dart
        usecases/
          login_usecase.dart
          logout_usecase.dart
          get_me_usecase.dart
      presentation/
        providers/
          auth_provider.dart
          session_provider.dart
        screens/
          splash_screen.dart
          login_screen.dart
        widgets/
          login_form.dart

    camera_permission/
      presentation/
        providers/
          camera_permission_provider.dart
        screens/
          camera_permission_screen.dart

    locations/
      data/
        datasource/
          location_remote_datasource.dart
        models/
          location_model.dart
          create_location_request_model.dart
        repositories/
          location_repository_impl.dart
      domain/
        entities/
          location_entity.dart
        repositories/
          location_repository.dart
        usecases/
          get_locations_usecase.dart
          create_location_usecase.dart
      presentation/
        providers/
          locations_provider.dart
        widgets/
          location_dropdown.dart
          create_location_form.dart

    reports/
      data/
        datasource/
          report_remote_datasource.dart
        models/
          report_model.dart
          report_detail_model.dart
          create_report_request_model.dart
          upload_report_photos_request_model.dart
        repositories/
          report_repository_impl.dart
      domain/
        entities/
          report_entity.dart
          report_detail_entity.dart
        repositories/
          report_repository.dart
        usecases/
          create_report_usecase.dart
          get_my_reports_usecase.dart
          get_report_detail_usecase.dart
          upload_report_photos_usecase.dart
      presentation/
        providers/
          my_reports_provider.dart
          report_detail_provider.dart
          create_report_form_provider.dart
        screens/
          my_reports_screen.dart
          report_detail_screen.dart
          create_report_building_type_screen.dart
          create_report_location_screen.dart
          create_report_risk_level_screen.dart
          create_report_photos_screen.dart
          create_report_notes_screen.dart
          create_report_root_cause_screen.dart
          create_report_review_screen.dart
        widgets/
          report_card.dart
          risk_level_card.dart
          building_type_card.dart
          report_summary_section.dart

    pic/
      data/
        datasource/
          pic_remote_datasource.dart
        models/
          pic_report_model.dart
          create_followup_request_model.dart
          followup_model.dart
        repositories/
          pic_repository_impl.dart
      domain/
        entities/
          followup_entity.dart
        repositories/
          pic_repository.dart
        usecases/
          get_report_by_token_usecase.dart
          get_pic_tasks_usecase.dart
          create_followup_usecase.dart
      presentation/
        providers/
          pic_tasks_provider.dart
          pic_report_by_token_provider.dart
          create_followup_form_provider.dart
        screens/
          pic_tasks_screen.dart
          pic_report_detail_screen.dart
          followup_photos_screen.dart
          followup_action_notes_screen.dart
        widgets/
          pic_task_card.dart
          followup_summary_section.dart

  shared/
    models/
      api_pagination_model.dart
    enums/
      user_role.dart
      report_status.dart
      risk_level.dart
      building_type.dart

  main.dart
```

## Kenapa struktur ini dipilih
Karena proyek ini butuh:
- pemisahan fitur yang jelas
- reusable core layer
- AI agent bisa fokus per feature
- refactor lebih mudah

## Penjelasan layer

### app/
Semua yang berhubungan dengan konfigurasi aplikasi global.

### core/
Semua utilitas dan komponen reusable lintas fitur.

### features/
Semua logic bisnis dipisah berdasarkan fitur.

### shared/
Enum dan model umum yang dipakai banyak fitur.

## Rule penting folder
- screen hanya menangani layout dan orchestration ringan
- business logic masuk ke provider/usecase/repository
- widget reusable jangan ditaruh di screen file
- request/response model jangan dipakai langsung sebagai entity UI jika bisa dipisah

## Folder minimal yang wajib dibuat dulu
Jika ingin mulai cepat, buat urutan awal:
1. `app/`
2. `core/`
3. `features/auth/`
4. `features/reports/`
5. `features/locations/`
6. `features/pic/`
7. `shared/`

## File yang wajib ada di awal
- `main.dart`
- `app/app.dart`
- `app/router/app_router.dart`
- `app/theme/app_theme.dart`
- `core/network/api_client.dart`
- `core/storage/secure_storage_service.dart`
- `features/auth/presentation/providers/auth_provider.dart`
