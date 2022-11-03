package pl.kolak.myfinance;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class Controller {

    private final StorageService storageService;

    public Controller(StorageService storageService) {
        this.storageService = storageService;
    }

    @PostMapping()
    public void saveDataForReports(@RequestBody List<PersistedPayment> exportedData) {
        if (storageService.getAll().containsAll(exportedData)) {
            return;
        }

        storageService.cleanFromFalseIncomeAndSave(exportedData);
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
