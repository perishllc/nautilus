@echo Off

@REM this is a dumb hack for windows since the * in the bash version doesn't match files on windows

@REM original script:
@REM flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localization.dart
@REM flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb

cmd /C flutter pub pub run intl_generator:extract_to_arb --output-dir=lib/l10n lib/localization.dart

for /r %%f in (lib/l10n/*.arb) do (
    echo %%~nxf
    flutter pub pub run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localization.dart lib/l10n/%%~nxf
)