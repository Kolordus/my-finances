package pl.kolak.myfinance;


import org.springframework.stereotype.Service;

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
}
