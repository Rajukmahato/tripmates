import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/send_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/accept_request_usecase.dart';

class MockPartnerRequestRepository extends Mock
    implements PartnerRequestRepository {}

void main() {
  group('Partner Request Usecases', () {
    late MockPartnerRequestRepository mockPartnerRequestRepository;

    final tPartnerRequestEntity = PartnerRequestEntity(
      id: 'request1',
      senderId: 'user1',
      senderName: 'John Doe',
      senderAvatar: null,
      receiverId: 'user2',
      receiverName: 'Jane Smith',
      receiverAvatar: null,
      tripId: 'trip1',
      tripTitle: 'Paris Adventure',
      status: RequestStatus.pending,
      message: 'Would you like to join my trip?',
      createdAt: DateTime(2024, 6, 1),
      respondedAt: null,
    );

    setUp(() {
      mockPartnerRequestRepository = MockPartnerRequestRepository();
    });

    group('SendRequestUseCase', () {
      test('should send partner request successfully', () async {
        when(
          () => mockPartnerRequestRepository.sendRequest(
            receiverId: any(named: 'receiverId'),
            tripId: any(named: 'tripId'),
            message: any(named: 'message'),
          ),
        ).thenAnswer((_) async => Right(tPartnerRequestEntity));

        final sendRequestUseCase = SendRequestUseCase(
          mockPartnerRequestRepository,
        );

        final result = await sendRequestUseCase(
          receiverId: 'user2',
          tripId: 'trip1',
          message: 'Would you like to join my trip?',
        );

        expect(result, isA<Right<Failure, PartnerRequestEntity>>());
        final request = (result as Right).value;
        expect(request.id, equals('request1'));
        expect(request.status, equals(RequestStatus.pending));
        expect(request.tripTitle, equals('Paris Adventure'));
        verify(
          () => mockPartnerRequestRepository.sendRequest(
            receiverId: 'user2',
            tripId: 'trip1',
            message: 'Would you like to join my trip?',
          ),
        ).called(1);
      });
    });

    group('AcceptRequestUseCase', () {
      test('should accept partner request successfully', () async {
        final acceptedRequest = PartnerRequestEntity(
          id: 'request1',
          senderId: 'user1',
          senderName: 'John Doe',
          senderAvatar: null,
          receiverId: 'user2',
          receiverName: 'Jane Smith',
          receiverAvatar: null,
          tripId: 'trip1',
          tripTitle: 'Paris Adventure',
          status: RequestStatus.accepted,
          message: 'Would you like to join my trip?',
          createdAt: DateTime(2024, 6, 1),
          respondedAt: DateTime(2024, 6, 2),
        );

        when(
          () => mockPartnerRequestRepository.acceptRequest(any()),
        ).thenAnswer((_) async => Right(acceptedRequest));

        final acceptRequestUseCase = AcceptRequestUseCase(
          mockPartnerRequestRepository,
        );

        final result = await acceptRequestUseCase('request1');

        expect(result, isA<Right<Failure, PartnerRequestEntity>>());
        final request = (result as Right).value;
        expect(request.status, equals(RequestStatus.accepted));
        expect(request.respondedAt, isNotNull);
        verify(
          () => mockPartnerRequestRepository.acceptRequest('request1'),
        ).called(1);
      });
    });
  });
}
