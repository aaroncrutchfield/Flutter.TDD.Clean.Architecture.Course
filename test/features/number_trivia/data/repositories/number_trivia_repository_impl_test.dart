import 'package:dartz/dartz.dart';
import 'package:flutter_tdd_arch/core/error/Failure.dart';
import 'package:flutter_tdd_arch/core/error/exceptions.dart';
import 'package:flutter_tdd_arch/core/platform/network_info.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd_arch/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_tdd_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repositoryImpl;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repositoryImpl = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  /// GET CONCRETE NUMBER TRIVIA
  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      repositoryImpl.getConcreteNumberTrivia(tNumber);

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());

        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow((CacheException()));

        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });


  /// GET RANDOM NUMBER TRIVIA
  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
    NumberTriviaModel(text: 'test trivia', number: 123);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      repositoryImpl.getRandomNumberTrivia();

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // Arrange
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            // Act
            final result = await repositoryImpl.getRandomNumberTrivia();

            // Assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // Arrange
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            // Act
            final result = await repositoryImpl.getRandomNumberTrivia();

            // Assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // Arrange
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenThrow(ServerException());

            // Act
            final result = await repositoryImpl.getRandomNumberTrivia();

            // Assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runTestOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
              () async {
            // Arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            // Act
            final result = await repositoryImpl.getRandomNumberTrivia();

            // Assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test('should return CacheFailure when there is no cached data present',
              () async {
            // Arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenThrow((CacheException()));

            // Act
            final result = await repositoryImpl.getRandomNumberTrivia();

            // Assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Left(CacheFailure())));
          });
    });
  });
}
