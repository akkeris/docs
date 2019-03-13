# Troubleshooting Memory Issues in Java

<!-- toc -->

## Introduction

Java and older JVM versions prior to 1.9 may experience issues running on Akkeris due ot the nature in how Java queries the available underlying memory of the system. This difference in how memory is assessed will cause Java to attempt to see more memory to exist than is actual available to it and will be killed or crash with a `R14 - Out of Memory` or `Memory Quota Exceeded` error from the platform.  In addition, you may see `OutOfHeapException`. 

## Setting Java Options

Setting the `JAVA_OPTS` maximum heap value (e.g., `-Xmx2048M` for 2 Gigabytes) will prevent Java from consuming more than the set value in heap size. While this may not fully solve the issues it should be able to significantly reduce out of memory errors.  It's recommended this value be set to 75% of the total memory available to the app.  For example, if you have a 2GB memory dyno this value would be `-Xmx1536`, this is necessary to give both the Java Garbage Collector and stack plenty of room to operate as well.

This however is not full proof, as Java may still request above the 2GB limit and only limit its heap with this option.

## Setting CGroup Memory Limits

Java 8u131+ and starting in JDK9 enables using cgroups in linux and Akkeris for tracking memory use, this fixes the issue. If you're using Java 8u131+ or JDK9, you can enable cgroup memory limits by adding `-XX:+UseCGroupMemoryLimitForHeap -XX:+UnlockExperimentalVMOptions` to the `JAVA_OPTS`.

For more information related to this see:

* [Java SE support for Docker CPU and memory limits](https://blogs.oracle.com/java-platform-group/java-se-support-for-docker-cpu-and-memory-limits)
* [Swapping, memory limits and cgroups](https://jvns.ca/blog/2017/02/17/mystery-swap/)
