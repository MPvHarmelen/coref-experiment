#! /usr/bin/env python3
import re


TESTING = False

if TESTING:
    from io import StringIO

    # Test data with only spaces
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

    # Test data with tabs AND a rounded `22` at `Non-coreference links`
    TEST_DATA_2 = StringIO("""
====== TOTALS =======
Identification of Mentions: Recall: (6381 / 13079) 48.78%	Precision: (6381 / 14255) 44.76%	F1: 46.68%
--------------------------------------------------------------------------

Coreference:
Coreference links: Recall: (9091 / 53207) 17.08%	Precision: (9091 / 186363) 4.87%	F1: 7.58%
--------------------------------------------------------------------------
Non-coreference links: Recall: (1050097 / 4362646) 24.07%	Precision: (1050097 / 5181026) 20.26%	F1: 22%
--------------------------------------------------------------------------
BLANC: Recall: (0.205781417699209 / 1) 20.57%	Precision: (0.125731212885415 / 1) 12.57%	F1: 14.79%
--------------------------------------------------------------------------
""")  # noqa

REGEX = r"""
====== TOTALS =======
Identification of Mentions: Recall: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+Precision: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+F1: (\d+(?:\.\d+)?)%
--------------------------------------------------------------------------

Coreference:
Coreference links: Recall: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+Precision: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+F1: (\d+(?:\.\d+)?)%
--------------------------------------------------------------------------
Non-coreference links: Recall: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+Precision: \(\d+ / \d+\) (\d+(?:\.\d+)?)%\s+F1: (\d+(?:\.\d+)?)%
--------------------------------------------------------------------------
BLANC: Recall: \(0\.\d+ / \d+\) (\d+\.\d+)%\s+Precision: \(0(?:\.\d+)? / \d+\) (\d+(?:\.\d+)?)%\s+F1: (\d+(?:\.\d+)?)%
--------------------------------------------------------------------------
"""  # noqa

OUTPUT = """
Description                 | Recall | Precision | F1
-----------                 | -----: | --------: | --:
Identification of mentions  |  {:>5.2f} |     {:>5.2f} | {:>5.2f}
Coreference links           |  {:>5.2f} |     {:>5.2f} | {:>5.2f}
Non-coreference links       |  {:>5.2f} |     {:>5.2f} | {:>5.2f}
BLANC                       |  {:>5.2f} |     {:>5.2f} | {:>5.2f}
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

    if not TESTING:
        with fileinput.input() as input_lines:
            data = ''.join(last(regex_size, input_lines))
    else:
        for i, data in enumerate([TEST_DATA, TEST_DATA_2]):
            data = ''.join(last(regex_size, data))

            for regex, line in zip(REGEX.split('\n'), data.split('\n')):
                if not re.match(regex, line):
                    for regex, part in zip(regex.split(':'), line.split(':')):
                        if not re.match(regex, part):
                            raise ValueError(
                                "Could not match the following regular"
                                " expression with the following part. Expected"
                                f" something matching:\n{regex}\nGot:\n"
                                f"{part!r}\nfrom test data #{i} in the"
                                f" following line:\n{line!r}")

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
