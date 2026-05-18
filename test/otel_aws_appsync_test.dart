// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_aws_appsync/otel_aws_appsync.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_aws_appsync-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('graphql.query records op + auth + cache hit', () async {
    await tracedAwsAppSync<String>(
      operation: 'graphql.query',
      invoke: () async => const AwsAppSyncCallResult(
        value: 'ok',
        result: AwsAppSyncResult(
          region: 'us-east-1',
          apiId: 'abc123',
          apiKind: 'GRAPHQL',
          authMode: 'AMAZON_COGNITO_USER_POOLS',
          graphqlOperation: 'query',
          operationName: 'GetUser',
          dataSourceKind: 'AMAZON_DYNAMODB',
          resolverKind: 'PIPELINE',
          resolverRuntime: 'APPSYNC_JS',
          cacheHit: true,
          cacheTtlSec: 60,
          fieldCount: 18,
          errorCount: 0,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_appsync graphql.query')!);
    expect(a['aws_appsync.auth.mode'], 'AMAZON_COGNITO_USER_POOLS');
    expect(a['aws_appsync.cache.hit'], true);
    expect(a['aws_appsync.resolver.runtime'], 'APPSYNC_JS');
  });

  test('GraphQL errors set span error', () async {
    await tracedAwsAppSync<String>(
      operation: 'graphql.query',
      invoke: () async => const AwsAppSyncCallResult(
        value: 'ok',
        result: AwsAppSyncResult(
          graphqlOperation: 'query',
          errorCount: 2,
        ),
      ),
    );
    expect(
      spans.findSpanByName('aws_appsync graphql.query')!.status,
      SpanStatusCode.Error,
    );
  });

  test('subscription records protocol + subscription id', () async {
    await tracedAwsAppSync<String>(
      operation: 'graphql.subscribe',
      invoke: () async => const AwsAppSyncCallResult(
        value: 'ok',
        result: AwsAppSyncResult(
          graphqlOperation: 'subscription',
          realtimeProtocol: 'WS_REAL_TIME',
          subscriptionId: 'sub_1',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_appsync graphql.subscribe')!);
    expect(a['aws_appsync.realtime.protocol'], 'WS_REAL_TIME');
  });

  test('suppression skips spans', () async {
    await runWithoutAwsAppSyncInstrumentationAsync(() async {
      await tracedAwsAppSync<String>(
        operation: 'api.list',
        invoke: () async => const AwsAppSyncCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('aws_appsync '), isEmpty);
  });
}
