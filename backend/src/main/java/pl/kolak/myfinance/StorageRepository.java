package pl.kolak.myfinance;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StorageRepository extends MongoRepository<PersistedPayment, String> {

    List<PersistedPayment> findAllByPaymentTypeEquals(String income);
}
