#! /usr/bin/env python3
import re
from io import StringIO


TEST_DATA = StringIO("""
====== TOTALS =======
Identification of Mentions: Recall: (6380 / 13079) 48.78%   Precision: (6380 / 14252) 44.76%    F1: 46.68%
--------------------------------------------------------------------------

Coreference:
Coreference links: Recall: (8946 / 53207) 16.81%    Precision: (8946 / 174883) 5.11%    F1: 7.84%
--------------------------------------------------------------------------
Non-coreference links: Recall: (1054572 / 4362646) 24.17%   Precision: (1054572 / 5190430) 20.31%   F1: 22.7%
--------------------------------------------------------------------------
BLANC: Recall: (0.20493169185248 / 1) 20.49%    Precision: (0.127165215168563 / 1) 12.71%   F1: 14.96%
--------------------------------------------------------------------------
""")  # noqa

REGEX = r"""
====== TOTALS =======
Identification of Mentions: Recall: \(\d+ / \d+\) (\d+\.\d+)%\s+Precision: \(\d+ / \d+\) (\d+\.\d+)%\s+F1: (\d+\.\d+)%
--------------------------------------------------------------------------

Coreference:
Coreference links: Recall: \(\d+ / \d+\) (\d+\.\d+)%\s+Precision: \(\d+ / \d+\) (\d+\.\d+)%\s+F1: (\d+\.\d+)%
--------------------------------------------------------------------------
Non-coreference links: Recall: \(\d+ / \d+\) (\d+\.\d+)%\s+Precision: \(\d+ / \d+\) (\d+\.\d+)%\s+F1: (\d+\.\d+)%
--------------------------------------------------------------------------
BLANC: Recall: \(0\.\d+ / \d+\) (\d+\.\d+)%\s+Precision: \(0\.\d+ / \d+\) (\d+\.\d+)%\s+F1: (\d+\.\d+)%
--------------------------------------------------------------------------
"""  # noqa

OUTPUT = """
Description                 | Recall    | Precision | F1
-----------                 | -----:    | --------: | --:
Identification of mentions  |     {:>5.2f} |     {:>5.2f} | {:>5.2f}
Coreference links           |     {:>5.2f} |     {:>5.2f} | {:>5.2f}
Non-coreference links       |     {:>5.2f} |     {:>5.2f} | {:>5.2f}
BLANC                       |     {:>5.2f} |     {:>5.2f} | {:>5.2f}
"""


def last(size, iterator):
    """
    Get the last `size` items of `iterator`
    """
    memmory = [None] * size
    pointer = 0
    for item in iterator:
        memmory[pointer] = item
        pointer = (pointer + 1) % size

    return memmory[pointer:] + memmory[:pointer]


if __name__ == '__main__':
    import fileinput

    regex_size = REGEX.count('\n')

    with fileinput.input() as input_lines:
        data = ''.join(last(regex_size, input_lines))
    # data = ''.join(last(regex_size, TEST_DATA))

    match = re.match(REGEX, data)
    if match is not None:
        print(OUTPUT.format(*map(float, match.groups())), end='')
    else:
        raise ValueError(
            f"The last {regex_size} lines of the input did not match the"
            f" regular expression. Expected something matching:\n"
            f"(data starts directly after this line)\n{REGEX}\n"
            "(data ended directly before this line)\n\n"
            "Got:\n"
            f"(data starts directly after this line)\n{data}\n"
            "(data ended directly before this line)"
        )
