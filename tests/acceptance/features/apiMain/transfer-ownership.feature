@api
Feature: transfer-ownership

  @smokeTest
  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of a file
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/somefile.txt"
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/somefile.txt" for user "user1" with range "bytes=0-6" from the last received transfer folder should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of a file after updating the file
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has uploaded file "filesForUpload/file_to_overwrite.txt" to "/PARENT/textfile0.txt"
    And user "user0" has uploaded the following "3" chunks to "/PARENT/textfile0.txt" with old chunking
      | 1 | AA |
      | 2 | BB |
      | 3 | CC |
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/PARENT/textfile0.txt" for user "user1" with range "bytes=0-5" from the last received transfer folder should be "AABBCC"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of a folder
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user1" with range "bytes=0-6" from the last received transfer folder should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of file shares
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/somefile.txt"
    And user "user0" has shared file "/somefile.txt" with user "user2" with permissions 19
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder shared with third user
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with user "user2" with permissions 31
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder shared with transfer recipient
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with user "user1" with permissions 31
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/test" should not exist
    And the downloaded content when downloading file "/test/somefile.txt" for user "user1" with range "bytes=0-6" from the last received transfer folder should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder doubly shared with third user
    Given group "group1" has been created
    And user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user2" has been added to group "group1"
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with group "group1" with permissions 31
    And user "user0" has shared folder "/test" with user "user2" with permissions 31
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership does not transfer received shares
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user2" has created folder "/test"
    And user "user2" has shared folder "/test" with user "user0" with permissions 31
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/test" should not exist in the last received transfer folder

  @local_storage @skipOnEncryptionType:user-keys
  Scenario: transferring ownership does not transfer external storage
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/local_storage" should not exist in the last received transfer folder

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership does not fail with shared trashed files
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has created folder "/sub"
    And user "user0" has created folder "/sub/test"
    And user "user0" has shared folder "/sub/test" with user "user2" with permissions 31
    And user "user0" has deleted folder "/sub"
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful

  Scenario: transferring ownership fails with invalid source user
    Given user "user0" has been created with default attributes
    When the administrator transfers ownership from "invalid_user" to "user0" using the occ command
    Then the command output should contain the text "Unknown source user"
    And the command should have failed with exit code 1

  Scenario: transferring ownership fails with invalid destination user
    Given user "user0" has been created with default attributes
    When the administrator transfers ownership from "user0" to "invalid_user" using the occ command
    Then the command output should contain the text "Unknown destination user"
    And the command should have failed with exit code 1

  @smokeTest
  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of only a single folder containing a file
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user1" with range "bytes=0-6" from the last received transfer folder should be "This is"

  Scenario: transferring ownership of only a single folder containing an empty folder
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has created folder "/test/subfolder"
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/test" should exist in the last received transfer folder
    And as "user1" folder "/test/subfolder" should exist in the last received transfer folder

  Scenario: transferring ownership of an account containing only an empty folder
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has deleted everything from folder "/"
    And user "user0" has created folder "/test"
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/test" should exist in the last received transfer folder

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of file shares
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared file "/test/somefile.txt" with user "user2" with permissions 19
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys @public_link_share-feature-required
  Scenario: transferring ownership of folder shares which has public link
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with user "user2" with permissions 31
    And user "user1" has created a public link share with settings
      | path | /test/somefile.txt |
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder shared with third user
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with user "user2" with permissions 31
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder shared with transfer recipient
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with user "user1" with permissions 31
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/test" should not exist
    And the downloaded content when downloading file "/test/somefile.txt" for user "user1" with range "bytes=0-6" from the last received transfer folder should be "This is"

  @skipOnEncryptionType:user-keys
  Scenario: transferring ownership of folder doubly shared with third user
    Given group "group1" has been created
    And user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user2" has been added to group "group1"
    And user "user0" has created folder "/test"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" has shared folder "/test" with group "group1" with permissions 31
    And user "user0" has shared folder "/test" with user "user2" with permissions 31
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And the downloaded content when downloading file "/test/somefile.txt" for user "user2" with range "bytes=0-6" should be "This is"

  Scenario: transferring ownership does not transfer received shares
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user2" has been created with default attributes
    And user "user2" has created folder "/test"
    And user "user0" has created folder "/sub"
    And user "user2" has shared folder "/test" with user "user0" with permissions 31
    And user "user0" has moved folder "/test" to "/sub/test"
    When the administrator transfers ownership of path "sub" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/sub/test" should not exist in the last received transfer folder

  @skipOnEncryptionType:user-keys @public_link_share-feature-required
  Scenario: transferring ownership of folder shared with transfer recipient and public link created of received share works
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/test"
    And user "user0" has created folder "/test/foo"
    And user "user0" has uploaded file "filesForUpload/textfile.txt" to "/test/somefile.txt"
    And user "user0" creates a public link share using the sharing API with settings
      | path | /test/somefile.txt |
    And user "user0" has shared file "/test" with user "user1" with permissions 31
    And user "user1" creates a public link share using the sharing API with settings
      | path | /test |
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user0" folder "/test" should not exist

  @local_storage
  Scenario: transferring ownership does not transfer external storage
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has created folder "/sub"
    When the administrator transfers ownership of path "sub" from "user0" to "user1" using the occ command
    Then the command should have been successful
    And as "user1" folder "/local_storage" should not exist in the last received transfer folder

  Scenario: transferring ownership fails with invalid source user
    Given user "user0" has been created with default attributes
    And user "user0" has created folder "/sub"
    When the administrator transfers ownership of path "sub" from "invalid_user" to "user0" using the occ command
    Then the command output should contain the text "Unknown source user"
    And the command should have failed with exit code 1

  Scenario: transferring ownership fails with invalid destination user
    Given user "user0" has been created with default attributes
    And user "user0" has created folder "/sub"
    When the administrator transfers ownership of path "sub" from "user0" to "invalid_user" using the occ command
    Then the command output should contain the text "Unknown destination user"
    And the command should have failed with exit code 1

  Scenario: transferring ownership fails with invalid path
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    When the administrator transfers ownership of path "test" from "user0" to "user1" using the occ command
    Then the command output should contain the text "Unknown path provided"
    And the command should have failed with exit code 1

  Scenario: transferring ownership fails with empty files
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes
    And user "user0" has deleted everything from folder "/"
    When the administrator transfers ownership from "user0" to "user1" using the occ command
    Then the command output should contain the text "No files/folders to transfer"
    And the command should have failed with exit code 1