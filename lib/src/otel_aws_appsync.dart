// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_aws_appsync_suppression.dart';

const _tracerName = 'dartastic_otel_libs_aws_appsync';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AwsAppSyncResult {
  const AwsAppSyncResult({
    this.region,
    this.apiId,
    this.apiKind,
    this.authMode,
    this.graphqlOperation,
    this.operationName,
    this.complexity,
    this.depth,
    this.fieldCount,
    this.errorCount,
    this.cacheHit,
    this.cacheTtlSec,
    this.dataSource,
    this.dataSourceKind,
    this.resolverKind,
    this.resolverRuntime,
    this.realtimeProtocol,
    this.subscriptionId,
    this.requestBytes,
    this.responseBytes,
    this.errorType,
    this.errorMessage,
    this.statusCode,
  });

  final String? region;

  /// AppSync API id (logical or `<id>.appsync-api.<region>.amazonaws.com`).
  final String? apiId;

  /// `GRAPHQL`, `MERGED`, `EVENTS`.
  final String? apiKind;

  /// `API_KEY`, `AWS_IAM`, `AMAZON_COGNITO_USER_POOLS`,
  /// `OPENID_CONNECT`, `AWS_LAMBDA`.
  final String? authMode;

  /// `query`, `mutation`, `subscription`.
  final String? graphqlOperation;
  final String? operationName;

  /// Cost-analysis complexity (when enabled).
  final int? complexity;
  final int? depth;
  final int? fieldCount;
  final int? errorCount;

  final bool? cacheHit;
  final int? cacheTtlSec;

  /// Resolved data source name.
  final String? dataSource;

  /// `AMAZON_DYNAMODB`, `AMAZON_ELASTICSEARCH`, `AMAZON_OPENSEARCH_SERVICE`,
  /// `AWS_LAMBDA`, `HTTP`, `RELATIONAL_DATABASE`, `NONE`, `EVENT_BRIDGE`,
  /// `AMAZON_BEDROCK_RUNTIME`.
  final String? dataSourceKind;

  /// `UNIT`, `PIPELINE`.
  final String? resolverKind;

  /// `APPSYNC_JS`, `VTL`.
  final String? resolverRuntime;

  /// `WS`, `MQTT_OVER_WSS`, `WS_REAL_TIME` (subscription transport).
  final String? realtimeProtocol;
  final String? subscriptionId;

  final int? requestBytes;
  final int? responseBytes;

  /// `UnauthorizedException`, `BadRequestException`,
  /// `LimitExceededException`, `NotFoundException`,
  /// `ConflictException`, `InternalFailureException`,
  /// `ConcurrentModificationException`, `ApiKeyLimitExceededException`,
  /// `ApiLimitExceededException`.
  final String? errorType;
  final String? errorMessage;

  final int? statusCode;
}

class AwsAppSyncCallResult<T> {
  const AwsAppSyncCallResult({required this.value, this.result});
  final T value;
  final AwsAppSyncResult? result;
}

/// Wraps an AWS AppSync call in a CLIENT span. [operation] is one of
/// `graphql.query`, `graphql.mutate`, `graphql.subscribe`,
/// `graphql.unsubscribe`, `events.publish`, `events.subscribe`,
/// `api.create`, `api.delete`, `api.update`, `api.list`,
/// `apiKey.create`, `apiKey.delete`, `apiKey.list`,
/// `dataSource.create`, `dataSource.delete`, `dataSource.update`,
/// `resolver.create`, `resolver.delete`, `resolver.update`,
/// `function.create`, `function.delete`, `function.update`,
/// `schema.create`, `schema.startCreation`, `schema.getStatus`,
/// `mergedApi.associate`, `mergedApi.disassociate`,
/// `cache.flush`, `cache.update`, `customDomain.create`,
/// `customDomain.delete`, `customDomain.associate`.
Future<T> tracedAwsAppSync<T>({
  required String operation,
  required Future<AwsAppSyncCallResult<T>> Function() invoke,
}) async {
  if (awsAppSyncInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'aws_appsync',
    'rpc.method': operation,
    'aws_appsync.operation': operation,
  };

  final span = _tracer().startSpan(
    'aws_appsync $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.region != null) {
        extras.add(OTel.attributeString('aws_appsync.region', res.region!));
      }
      if (res.apiId != null) {
        extras.add(OTel.attributeString('aws_appsync.api.id', res.apiId!));
      }
      if (res.apiKind != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.api.kind',
          res.apiKind!,
        ));
      }
      if (res.authMode != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.auth.mode',
          res.authMode!,
        ));
      }
      if (res.graphqlOperation != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.graphql.operation',
          res.graphqlOperation!,
        ));
      }
      if (res.operationName != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.graphql.operation_name',
          res.operationName!,
        ));
      }
      if (res.complexity != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.graphql.complexity',
          res.complexity!,
        ));
      }
      if (res.depth != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.graphql.depth',
          res.depth!,
        ));
      }
      if (res.fieldCount != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.graphql.field_count',
          res.fieldCount!,
        ));
      }
      if (res.errorCount != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.graphql.error_count',
          res.errorCount!,
        ));
        if (res.errorCount! > 0) {
          span.setStatus(
            SpanStatusCode.Error,
            'AppSync ${res.errorCount} GraphQL error(s)',
          );
        }
      }
      if (res.cacheHit != null) {
        extras.add(OTel.attributeBool(
          'aws_appsync.cache.hit',
          res.cacheHit!,
        ));
      }
      if (res.cacheTtlSec != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.cache.ttl_sec',
          res.cacheTtlSec!,
        ));
      }
      if (res.dataSource != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.data_source',
          res.dataSource!,
        ));
      }
      if (res.dataSourceKind != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.data_source.kind',
          res.dataSourceKind!,
        ));
      }
      if (res.resolverKind != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.resolver.kind',
          res.resolverKind!,
        ));
      }
      if (res.resolverRuntime != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.resolver.runtime',
          res.resolverRuntime!,
        ));
      }
      if (res.realtimeProtocol != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.realtime.protocol',
          res.realtimeProtocol!,
        ));
      }
      if (res.subscriptionId != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.subscription.id',
          res.subscriptionId!,
        ));
      }
      if (res.requestBytes != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.request.bytes',
          res.requestBytes!,
        ));
      }
      if (res.responseBytes != null) {
        extras.add(OTel.attributeInt(
          'aws_appsync.response.bytes',
          res.responseBytes!,
        ));
      }
      if (res.errorType != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.error.type',
          res.errorType!,
        ));
        span.setStatus(SpanStatusCode.Error, 'AppSync ${res.errorType}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'aws_appsync.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'AppSync HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
