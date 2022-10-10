package pl.kolak.myfinance;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class Controller {

    private final StorageService storageService;

    public Controller(StorageService storageService) {
        this.storageService = storageService;
    }

    @PostMapping
    public void exportData(@RequestBody List<PersistedPayment> exportedData) {
        storageService.saveAll(exportedData);
    }

    @GetMapping
    public List<PersistedPayment> importData() {
        storageService.purgeData();
        return storageService.getAll();
    }

    @DeleteMapping
    public void deleteSavedEntries() {
        storageService.purgeData();
    }

}
