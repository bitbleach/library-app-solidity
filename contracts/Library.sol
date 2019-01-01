pragma solidity ^0.4.23;

import './lib/Ownable.sol';
import './lib/SafeMath.sol';

/* Assumptions
1) Owner has librarian privileges
2) Book must be in library to checkout
3) Damage and repair can be written in as strings
4) User cannot transfer book to themselves
5) Book must be checked out before it can be checked in
6) Anyone can record damage and repair
*/

contract Library is Ownable {
  using SafeMath for uint256;

  event NewBook(string title);
  event NewBookOwner(address oldOwner, address newOwner, uint bookId);
  event BookAddedToLibrary(uint bookId);
  event BookRemovedFromLibrary(uint bookId);
  event BookCheckedOutOfLibrary(uint bookId);
  event BookCheckedInToLibrary(uint bookId);
  event BookHistoryChanged(uint bookId, string action, uint time);

  mapping (address => bool) 			public librarians;
  mapping (uint => bool) 					public bookInLibrary;
  mapping (uint => address) 			public bookToOwner;
  mapping (uint => BookHistory[]) public bookHistory;

  mapping (address => mapping (uint => bool)) public bookCheckedOutTo;

  struct BookHistory {
    string  action;
    uint    time;
    address owner;
  }

  struct Book {
    string title;
  }

  BookHistory[] public bookHistories;
  Book[] public books;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyLibrarian {
    require(msg.sender == owner || librarians[msg.sender]);
    _;
  }

  function setLibrarian(address librarian, bool isLibrarian) onlyOwner public {
    librarians[librarian] = isLibrarian;
  }

 	function createBook(string title) public {
    uint id = books.push(Book(title)) - 1;
    bookHistory[id].push(BookHistory("created", now, msg.sender));
    bookToOwner[id] = msg.sender;
    emit NewBook(title);
 	}

  function addBookToLibrary(uint bookId) onlyLibrarian public {
  	bookInLibrary[bookId] = true;
    emit BookAddedToLibrary(bookId);
  }

  function removeBookFromLibrary(uint bookId) onlyLibrarian public {
  	bookInLibrary[bookId] = false;
    emit BookRemovedFromLibrary(bookId);
	}

  function checkBookOut(uint bookId, address bookUser) onlyLibrarian public {
  	require(bookInLibrary[bookId] == true);
  	bookCheckedOutTo[bookUser][bookId] = true;
    emit BookCheckedOutOfLibrary(bookId);
  }

  function checkBookIn(uint bookId, address bookUser) public {
  	require(bookCheckedOutTo[bookUser][bookId] == true);
  	bookCheckedOutTo[bookUser][bookId] = false;
    emit BookCheckedInToLibrary(bookId);
  }

  function viewBookHistory(uint bookId, uint index) public constant returns(string, uint256, address) {
  	return (bookHistory[bookId][index].action, bookHistory[bookId][index].time, bookHistory[bookId][index].owner);
  }

  function addBookHistory(uint bookId, string action) public {
  	bookHistory[bookId].push(BookHistory(action, now, bookToOwner[bookId]));
    emit BookHistoryChanged(bookId, action, now);
  }

  function changeBookOwner(uint bookId, address newOwner) public  {
  	require(bookToOwner[bookId] == msg.sender);
    require(newOwner != msg.sender);
    address oldOwner = bookToOwner[bookId];
  	bookToOwner[bookId] = newOwner;
  	bookHistory[bookId].push(BookHistory("new owner", now, bookToOwner[bookId]));
    emit NewBookOwner(oldOwner, newOwner, bookId);
  }
}




