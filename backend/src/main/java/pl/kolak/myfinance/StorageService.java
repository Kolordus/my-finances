package pl.kolak.myfinance;


import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class StorageService {

    private final StorageRepository storageRepository;

    public StorageService(StorageRepository storageRepository) {
        this.storageRepository = storageRepository;
    }

    public void saveAll(List<PersistedPayment> list) {
        storageRepository.saveAll(list);
    }

    public List<PersistedPayment> getAll() {
        return storageRepository.findAll();
    }

    public void purgeData() {
        storageRepository.deleteAll();
    }

    public void cleanFromFalseIncomeAndSave(List<PersistedPayment> exportedData) {
        PersistedPayment income = getIncomeFromGivenData(exportedData);
        List<PersistedPayment> incomesToDate = storageRepository.findAllByPaymentTypeEquals("INCOME");

        if (incomesToDate.contains(income)) {
            exportedData.remove(income);
        }

        storageRepository.saveAll(exportedData);
    }

    private PersistedPayment getIncomeFromGivenData(List<PersistedPayment> exportedData) {
        return exportedData.stream()
                .filter(pay -> pay.getPaymentType().equals("INCOME"))
                .findFirst()
                .orElseThrow();
    }
}
