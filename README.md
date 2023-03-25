# Proven_Components

This project contains reusable components written in SPARK.

Each component has been verified, usually to the Gold or Platinum level (the
highest SPARK levels). All components are proven at least to the Silver level.

As such, each component is proven to be free of run-time errors, including
array indexing errors, numeric range errors, numeric overflow/underflow errors,
reads of unassigned variables, unintended access to global data, and others.

In addition to those benefits, proof at the Gold level ensures that the
provided operations implement their functional requirements at the unit
level, obviating unit tests (or, if exercised, ensuring that the tests pass on
their first attempt). Proof at the Platinum level is similar, except that the
functional requirements are fully expressed for each unit (and proven).

For a fuller, detailed description of the proof levels and their benefits, see
the SPARK User Guide, starting in the section at this URL:
https://docs.adacore.com/spark2014-docs/html/ug/en/usage_scenarios.html#levels-of-spark-use

The subsection describing the Silver level is here:
https://docs.adacore.com/spark2014-docs/html/ug/en/usage_scenarios.html#silver-level-absence-of-run-time-errors-aorte

The subsections describing the Gold and Platinum levels follow the Silver level
section.

## Primary Reusable Components

Each reusable component is a generic package presenting an abstract data type
("ADT") that clients can use to declare and manipulate objects, such as stacks, buffers, and so on.

The names of the generic packages, and hence their files' names, reflect specific
characteristics of the components. For example:

* whether objects of the type are thread-safe,
* whether objects of the type are bounded or unbounded in their memory usage, and
* the general abstraction itself.

Thread-safety is indicated by either "sequential" or "concurrent" appearing the
name. Memory usage is indicated by either "bounded" or "unbounded" appearing
in the name.

For example, the file named "sequential_bounded_buffers.ads" contains the
generic package declaration for a buffer ADT. Objects of this type are not
protected from concurrent access and are bounded in memory usage.

The names can contain other indicators, as needed. For example the name might
include the word "discrete" to indicate that only discrete types are supported
(via the generic formal type).

## Reusable Utility Components

Some of the primary components are implemented with "utility" components.
Typically these facilitate proof, although that is not necessarily so. These
utility components are defined as reusable generics so that they can be used in
new components requiring verification, including user-defined components. These
generic packages are located in the "utils" subdirectory under the source
directory containing the primary components.

For example, a common implementation idiom uses an array of Boolean components,
in which each individual Boolean indicates something about the value
corresponding to that array component's index. A specific example is the "Set"
ADT that contains member values of some discrete type. The Boolean array is
indexed by the discrete "member" type. Thus each component value indicates set
membership, or lack thereof, for the corresponding member index value. One of
the Set operations indicates how many members are currently held by a Set
object. This corresponds to the total number of Boolean components that are
currently True. Other operations will add or remove an individual member of a
given set, incrementing or decrementing that total. Proof of the relationship
between individual array component changes and the total involves induction,
requiring lemmas. Therefore, the utility generic package Boolean_Array_Extent
provides a function Extent indicating the number of True components, and lemma
procedures facilitating proof of the incrementing/decrementing operations. New
primary components may reuse this generic package, but new user-defined
components can use it too.

## Demonstration Programs and Units

Each primary component contains a brief, non-exhaustive demonstration program.
These files are located in the "demos" subdirectory located under the source
directory containing the primary components. Each demonstration program is
written in SPARK and can be proven.

Note that the primary components, because they are generic packages, cannot
be proven in SPARK directly (at least not as of this writing). Instead, their
instantiations are supplied to SPARK for verification. Each demonstration
utilizes a separate instantiation of the corresponding primary component, and
it is these instances that have been proven in SPARK. Users can prove them too,
but the expectation is that instantiations specific to actual client code will
be proven by users.
