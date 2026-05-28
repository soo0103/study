package com.example.springboot.controllers;

import com.example.springboot.dto.TransferRequest;
import com.example.springboot.model.Account;
import com.example.springboot.services.TransferService;
import org.springframework.web.bind.annotation.*;

@RestController
public class AccountController {

    private final TransferService transferService;

    public AccountController(TransferService transferService) {
        this.transferService = transferService;
    }

    @PostMapping("/transfer")
    public void transferMoney(
            @RequestBody TransferRequest request) {

        transferService.transferMoney(
                        request.getSenderAccountId(),
                        request.getReceiverAccountId(),
                        request.getAmount());
    }

    @GetMapping("/accounts")
    public Iterable<Account> getAllAccounts(
            @RequestParam(required = false) String name) {

        if (name == null) {
            return transferService.getAllAcounts();
        } else {
            return transferService.findAccountsByName(name);
        }
    }
}
