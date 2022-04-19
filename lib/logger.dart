// Package imports:
import 'package:f_logs/f_logs.dart';
import 'package:stack_trace/stack_trace.dart';

void initLogger() {
  /// Configuration example 3 Format Custom
  LogsConfig config = FLog.getDefaultConfigurations()
    ..isDevelopmentDebuggingEnabled = true
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3
    ..formatType = FormatType.FORMAT_CUSTOM
    ..fieldOrderFormatCustom = [
      FieldName.TIMESTAMP,
      FieldName.LOG_LEVEL,
      FieldName.CLASSNAME,
      FieldName.METHOD_NAME,
      FieldName.TEXT,
      FieldName.EXCEPTION,
      FieldName.STACKTRACE
    ]
    ..customOpeningDivider = "{"
    ..customClosingDivider = "}";

  FLog.applyConfigurations(config);
}

void logInfo(String text) {
  var currentTrace = Trace.current();
  var className = currentTrace.frames[1].member!.split(".")[0];
  var methodName = currentTrace.frames[1].member!.split(".")[1];

  FLog.info(className: className, methodName: methodName, text: text);
}

void logWarn(String text) {
  var currentTrace = Trace.current();
  var className = currentTrace.frames[1].member!.split(".")[0];
  var methodName = currentTrace.frames[1].member!.split(".")[1];

  FLog.warning(className: className, methodName: methodName, text: text);
}

void logError(String text) {
  var currentTrace = Trace.current();
  var className = currentTrace.frames[1].member!.split(".")[0];
  var methodName = currentTrace.frames[1].member!.split(".")[1];

  FLog.error(className: className, methodName: methodName, text: text);
}

void exportLog() {
  FLog.exportLogs();
}
