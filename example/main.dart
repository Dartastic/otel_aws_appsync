// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_appsync/otel_aws_appsync.dart';

/// Traces AWS AppSync calls with OpenTelemetry.
///
/// `otel_aws_appsync` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AWS AppSync call in
/// [tracedAwsAppSync]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-appsync-example');

  // Wraps an AWS AppSync call in a CLIENT span.
  final awsAppSyncId = await tracedAwsAppSync<String>(
    operation: 'api.create',
    invoke: () async {
      // Make the AWS AppSync call here, then report what it returned.
      const id = 'aws_appsync_8f3a2c';
      return const AwsAppSyncCallResult(
          value: id,
          result: AwsAppSyncResult(
              region: 'us-east-1',
              apiId: '<id>.appsync-api.<region>.amazonaws.com',
              apiKind: 'GRAPHQL',
              authMode: 'API_KEY',
              graphqlOperation: 'query',
              operationName: 'example',
              complexity: 1,
              depth: 1,
              fieldCount: 3,
              errorCount: 3,
              cacheHit: true,
              cacheTtlSec: 1,
              dataSource: 'example',
              dataSourceKind: 'AMAZON_DYNAMODB',
              resolverKind: 'UNIT',
              resolverRuntime: 'APPSYNC_JS',
              realtimeProtocol: 'WS',
              subscriptionId: 'subscription_8f3a2c',
              requestBytes: 512,
              responseBytes: 512,
              errorType: 'UnauthorizedException',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedAwsAppSync api.create returned $awsAppSyncId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsAppSyncInstrumentationAsync.
  await runWithoutAwsAppSyncInstrumentationAsync(
    () => tracedAwsAppSync<String>(
      operation: 'api.create',
      invoke: () async {
        const id = 'aws_appsync_8f3a2c';
        return const AwsAppSyncCallResult(
            value: id,
            result: AwsAppSyncResult(
                region: 'us-east-1',
                apiId: '<id>.appsync-api.<region>.amazonaws.com',
                apiKind: 'GRAPHQL',
                authMode: 'API_KEY',
                graphqlOperation: 'query',
                operationName: 'example',
                complexity: 1,
                depth: 1,
                fieldCount: 3,
                errorCount: 3,
                cacheHit: true,
                cacheTtlSec: 1,
                dataSource: 'example',
                dataSourceKind: 'AMAZON_DYNAMODB',
                resolverKind: 'UNIT',
                resolverRuntime: 'APPSYNC_JS',
                realtimeProtocol: 'WS',
                subscriptionId: 'subscription_8f3a2c',
                requestBytes: 512,
                responseBytes: 512,
                errorType: 'UnauthorizedException',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
