const Library = artifacts.require('./Library.sol');

const Utils = require("./Utils.js");

contract('LibraryTest', (accounts) => {

    beforeEach(async () => {
        owner     = accounts[0];
        librarian = accounts[1];
        user      = accounts[2];        

        library = await Library.new();
    });

    it("only owner can add or remove new librarian", async () => {
        await library.setLibrarian(librarian, true, {from: owner});
        await library.setLibrarian(librarian, false, {from: owner});

        // Random person cannot set librarian
        await Utils.expectRevert(async () => {
            await library.setLibrarian(user, true, {from: user});
        });
    });

    it("anyone can create new book", async () => {
        await library.createBook("Book", {from: user});
    });

    it("librarian can add and remove book to library and checkout book, anyone can check in book", async () => {
        await library.setLibrarian(librarian, true, {from: owner});

        await library.createBook("Book", {from: user});
        // adds book to library
        await library.addBookToLibrary(0, {from: librarian});
        // checks out book with id 0, to user
        await library.checkBookOut(0, user, {from: librarian});
        // anyone can check in book
        await library.checkBookIn(0, user, {from: user});
        // removes book from library
        await library.removeBookFromLibrary(0, {from: librarian});
    });

    it("anyone can record damage and repair for book, and view book history", async () => {
        await library.createBook("Book", {from: user});

        await library.addBookHistory(0, 'Spill Damage', {from: user});
        let [action, time, owner] = await library.viewBookHistory(0, 1, {from: user});

        assert(action == 'Spill Damage', "Damage record works correctly");

        await library.addBookHistory(0, 'Repaired Damage', {from: user});
        [action, time, owner] = await library.viewBookHistory(0, 2, {from: user});

        assert(action == 'Repaired Damage', "Repaired damage record works correctly");
    });

    it("book owner can transfer book and view book ownership history", async () => {
        await library.createBook("Book", {from: user});

        let [action, time, owner] = await library.viewBookHistory(0, 0, {from: user});
        assert(owner == user, "original owner is user");

        await library.changeBookOwner(0, librarian, {from: user});
        [action, time, owner] = await library.viewBookHistory(0, 1, {from: user});
        assert(owner == librarian, "new owner is librarian");
    });
})
