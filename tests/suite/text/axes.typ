// Test variable font axes parameter.

--- text-axes-basic paged ---
// Test basic axes parameter with a dictionary.
// This test verifies that the axes parameter is accepted.
#set text(axes: (wght: 700))
Heavy text

--- text-axes-empty paged ---
// Test with empty axes dictionary.
#set text(axes: (:))
Normal text

--- text-axes-multiple paged ---
// Test multiple axes.
#set text(axes: (wght: 400, wdth: 100))
Normal width and weight

--- text-axes-bad-tag-length paged ---
// Error: 17-35 feature tag must be one to four characters in length
// Hint: 17-35 found 11 characters
// Hint: 17-35 occurred in tag at index 0 (`"verylongtag"`)
#set text(axes: (verylongtag: 400))

--- text-axes-bad-value-type paged ---
// Error: 17-32 expected float, found string
// Hint: 17-32 occurred in tag at index 0 (`"wght"`)
#set text(axes: (wght: "heavy"))
