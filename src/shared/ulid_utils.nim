import ulid
import std/algorithm

proc generateUlid*(): string =
  ## Generate a new ULID string
  return ulid.ulid()

proc generateUlidWithTime*(timestamp: int): string =
  ## Generate a ULID with specific timestamp
  return ulid.ulid(timestamp)

proc isValidUlid*(ulidStr: string): bool =
  ## Check if a string is a valid ULID format (26 characters, valid alphabet)
  if ulidStr.len != 26:
    return false
  
  # Check if all characters are in ULID alphabet
  const validChars = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  for c in ulidStr:
    if c notin validChars:
      return false
  return true

when isMainModule:
  import times
  
  # ULID使用例
  echo "=== ULID Usage Examples ==="
  
  # 新しいULIDを生成
  let id1 = generateUlid()
  echo "Generated ULID: ", id1
  
  # 別のULIDを生成
  let id2 = generateUlid()
  echo "Another ULID: ", id2
  
  # 特定のタイムスタンプでULIDを生成
  let timestamp = int(epochTime() * 1000)
  let id3 = generateUlidWithTime(timestamp)
  echo "ULID with timestamp: ", id3
  
  # ULIDの妥当性をチェック
  echo "Is valid ULID (", id1, "): ", isValidUlid(id1)
  echo "Is valid ULID (invalid): ", isValidUlid("invalid-ulid")
  echo "Is valid ULID (short): ", isValidUlid("123")
  
  # ULIDの特徴を表示
  echo "ULID length: ", id1.len
  echo "ULIDs are lexicographically sortable by timestamp"
  
  # 複数のULIDを生成して順序を確認
  echo "\n=== Sorting Test ==="
  var ulids: seq[string] = @[]
  for i in 1..5:
    ulids.add(generateUlid())
  
  echo "Generated ULIDs:"
  for ulid in ulids:
    echo "  ", ulid
  
  ulids.sort()
  echo "Sorted ULIDs:"
  for ulid in ulids:
    echo "  ", ulid