// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
  string[] loremIpsumWords = ["Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit.", "Vestibulum", "varius", "fermentum", "leo"];
  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("LoremIpsumNFT", "LOREM") {
    console.log("Lorem ipsum NFT contract.");
  }

  // Pick a random word from the array.
  function pickRandomWord(uint256 tokenId) public view returns (string memory) {
    // Disclaimer: not completely random but I don't want to use Chainlink here as it's just a learning project.
    uint256 rand = random(string(abi.encodePacked("LOREM_IPSUM", Strings.toString(tokenId))));

    rand = rand % loremIpsumWords.length;
    return loremIpsumWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    // Randomly grab one word from the three array.
    // Concatenate it all together, and then close the <text> and <svg> tags.
    string memory randomWord = pickRandomWord(newItemId);
    string memory finalSvg = string(abi.encodePacked(baseSvg, randomWord, "</text></svg>"));

    // Base64 encode the JSON metadata.
    // Set the title of our NFT as randomWord.
    // Add data:image/svg+xml;base64 and then append our base64 encode our svg.
    string memory json = Base64.encode(bytes(string(abi.encodePacked(
      '{"name": "',
      randomWord,
      '", "description": "Beautiful collection of words coming from Lorem Ipsum.", "image": "data:image/svg+xml;base64,',
      Base64.encode(bytes(finalSvg)),
      '"}'
    ))));

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, finalTokenUri);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}
