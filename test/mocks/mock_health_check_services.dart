import 'package:mockito/annotations.dart';
import 'package:greenlands/core/services/health_check/claude_health_check_service.dart';
import 'package:greenlands/core/services/health_check/discord_health_check_service.dart';
import 'package:greenlands/core/services/health_check/slack_health_check_service.dart';
import 'package:greenlands/core/services/health_check/google_chat_health_check_service.dart';

@GenerateMocks([
  ClaudeHealthCheckService,
  DiscordHealthCheckService,
  SlackHealthCheckService,
  GoogleChatHealthCheckService,
])
void main() {}
