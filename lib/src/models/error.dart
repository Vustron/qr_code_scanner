import 'package:stack_trace/stack_trace.dart';
import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  const ErrorModel({
    required this.message,
    this.stackTrace,
  });

  final String message;
  final StackTrace? stackTrace;

  String formatStackTrace() {
    if (stackTrace == null) {
      return '';
    }
    final Trace trace = Trace.from(stackTrace!);
    return trace.terse.toString();
  }

  @override
  List<Object?> get props => <Object?>[message, stackTrace];
}
