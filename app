You are given a string S consisting of lowercase English letters. You need to transform this string into a new encrypted string using the following rules:

Each character in the string is replaced with its frequency followed by the character itself.
If a character appears consecutively, group them together and apply the transformation once.
The output string should be sorted in descending order of frequency. If two characters have the same frequency, maintain their original order from S.
Input:
A string S (1 ≤ |S| ≤ 10^5) containing only lowercase English letters.

Output:
Return the transformed and sorted string.

S = "aaabbcddd"
3a3d2b1c


S = "eeeffgggaa"
3e3g3a2f
