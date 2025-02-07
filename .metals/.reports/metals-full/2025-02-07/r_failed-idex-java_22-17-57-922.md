error id: jar:file:///C:/Users/Alpha/AppData/Local/Coursier/cache/v1/https/repo1.maven.org/maven2/org/apache/arrow/arrow-vector/0.8.0/arrow-vector-0.8.0-sources.jar!/codegen/templates/MapWriters.java
### java.lang.Exception: Unexpected symbol '#' at word pos: '35' Line: '<#list  ["Nullable", "Single"] as mode>'

Java indexer failed with and exception.
```Java
/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

<@pp.dropOutputFile />
<#list ["Nullable", "Single"] as mode>
<@pp.changeOutputFile name="/org/apache/arrow/vector/complex/impl/${mode}MapWriter.java" />
<#assign index = "idx()">
<#if mode == "Single">
<#assign containerClass = "MapVector" />
<#else>
<#assign containerClass = "NullableMapVector" />
</#if>

<#include "/@includes/license.ftl" />

package org.apache.arrow.vector.complex.impl;

<#include "/@includes/vv_imports.ftl" />
import java.util.Map;

import org.apache.arrow.vector.holders.RepeatedMapHolder;
import org.apache.arrow.vector.AllocationHelper;
import org.apache.arrow.vector.complex.reader.FieldReader;
import org.apache.arrow.vector.complex.writer.FieldWriter;

import com.google.common.collect.Maps;

/*
 * This class is generated using FreeMarker and the ${.template_name} template.
 */
@SuppressWarnings("unused")
public class ${mode}MapWriter extends AbstractFieldWriter {

  protected final ${containerClass} container;
  private int initialCapacity;
  private final Map<String, FieldWriter> fields = Maps.newHashMap();
  public ${mode}MapWriter(${containerClass} container) {
    <#if mode == "Single">
    if (container instanceof NullableMapVector) {
      throw new IllegalArgumentException("Invalid container: " + container);
    }
    </#if>
    this.container = container;
    this.initialCapacity = 0;
    for (Field child : container.getField().getChildren()) {
      MinorType minorType = Types.getMinorTypeForArrowType(child.getType());
      switch (minorType) {
      case MAP:
        map(child.getName());
        break;
      case LIST:
        list(child.getName());
        break;
      case UNION:
        UnionWriter writer = new UnionWriter(container.addOrGet(child.getName(), FieldType.nullable(MinorType.UNION.getType()), UnionVector.class), getNullableMapWriterFactory());
        fields.put(handleCase(child.getName()), writer);
        break;
<#list vv.types as type><#list type.minor as minor>
<#assign lowerName = minor.class?uncap_first />
<#if lowerName == "int" ><#assign lowerName = "integer" /></#if>
<#assign upperName = minor.class?upper_case />
      case ${upperName}: {
        <#if minor.typeParams?? >
        ${minor.arrowType} arrowType = (${minor.arrowType})child.getType();
        ${lowerName}(child.getName()<#list minor.typeParams as typeParam>, arrowType.get${typeParam.name?cap_first}()</#list>);
        <#else>
        ${lowerName}(child.getName());
        </#if>
        break;
      }
</#list></#list>
        default:
          throw new UnsupportedOperationException("Unknown type: " + minorType);
      }
    }
  }

  protected String handleCase(final String input) {
    return input.toLowerCase();
  }

  protected NullableMapWriterFactory getNullableMapWriterFactory() {
    return NullableMapWriterFactory.getNullableMapWriterFactoryInstance();
  }

  @Override
  public int getValueCapacity() {
    return container.getValueCapacity();
  }

  public void setInitialCapacity(int initialCapacity) {
    this.initialCapacity = initialCapacity;
    container.setInitialCapacity(initialCapacity);
  }

  @Override
  public boolean isEmptyMap() {
    return 0 == container.size();
  }

  @Override
  public Field getField() {
      return container.getField();
  }

  @Override
  public MapWriter map(String name) {
    String finalName = handleCase(name);
    FieldWriter writer = fields.get(finalName);
    if(writer == null){
      int vectorCount=container.size();
      NullableMapVector vector = container.addOrGet(name, FieldType.nullable(MinorType.MAP.getType()), NullableMapVector.class);
      writer = new PromotableWriter(vector, container, getNullableMapWriterFactory());
      if(vectorCount != container.size()) {
        writer.allocate();
      }
      writer.setPosition(idx());
      fields.put(finalName, writer);
    } else {
      if (writer instanceof PromotableWriter) {
        // ensure writers are initialized
        ((PromotableWriter)writer).getWriter(MinorType.MAP);
      }
    }
    return writer;
  }

  @Override
  public void close() throws Exception {
    clear();
    container.close();
  }

  @Override
  public void allocate() {
    container.allocateNew();
    for(final FieldWriter w : fields.values()) {
      w.allocate();
    }
  }

  @Override
  public void clear() {
    container.clear();
    for(final FieldWriter w : fields.values()) {
      w.clear();
    }
  }

  @Override
  public ListWriter list(String name) {
    String finalName = handleCase(name);
    FieldWriter writer = fields.get(finalName);
    int vectorCount = container.size();
    if(writer == null) {
      writer = new PromotableWriter(container.addOrGet(name, FieldType.nullable(MinorType.LIST.getType()), ListVector.class), container, getNullableMapWriterFactory());
      if (container.size() > vectorCount) {
        writer.allocate();
      }
      writer.setPosition(idx());
      fields.put(finalName, writer);
    } else {
      if (writer instanceof PromotableWriter) {
        // ensure writers are initialized
        ((PromotableWriter)writer).getWriter(MinorType.LIST);
      }
    }
    return writer;
  }

  public void setValueCount(int count) {
    container.setValueCount(count);
  }

  @Override
  public void setPosition(int index) {
    super.setPosition(index);
    for(final FieldWriter w: fields.values()) {
      w.setPosition(index);
    }
  }

  @Override
  public void start() {
    <#if mode == "Single">
    <#else>
    container.setIndexDefined(idx());
    </#if>
  }

  @Override
  public void end() {
    setPosition(idx()+1);
  }

  <#list vv.types as type><#list type.minor as minor>
  <#assign lowerName = minor.class?uncap_first />
  <#if lowerName == "int" ><#assign lowerName = "integer" /></#if>
  <#assign upperName = minor.class?upper_case />
  <#assign capName = minor.class?cap_first />
  <#assign vectName = capName />

  <#if minor.typeParams?? >
  @Override
  public ${minor.class}Writer ${lowerName}(String name) {
    // returns existing writer
    final FieldWriter writer = fields.get(handleCase(name));
    assert writer != null;
    return writer;
  }

  @Override
  public ${minor.class}Writer ${lowerName}(String name<#list minor.typeParams as typeParam>, ${typeParam.type} ${typeParam.name}</#list>) {
  <#else>
  @Override
  public ${minor.class}Writer ${lowerName}(String name) {
  </#if>
    FieldWriter writer = fields.get(handleCase(name));
    if(writer == null) {
      ValueVector vector;
      ValueVector currentVector = container.getChild(name);
      ${vectName}Vector v = container.addOrGet(name, 
          FieldType.nullable(
          <#if minor.typeParams??>
            <#if minor.arrowTypeConstructorParams??>
              <#assign constructorParams = minor.arrowTypeConstructorParams />
            <#else>
              <#assign constructorParams = [] />
              <#list minor.typeParams?reverse as typeParam>
                <#assign constructorParams = constructorParams + [ typeParam.name ] />
              </#list>
            </#if>    
            new ${minor.arrowType}(${constructorParams?join(", ")})
          <#else>
            MinorType.${upperName}.getType()
          </#if>
          ),
          ${vectName}Vector.class);
      writer = new PromotableWriter(v, container, getNullableMapWriterFactory());
      vector = v;
      if (currentVector == null || currentVector != vector) {
        if(this.initialCapacity > 0) {
          vector.setInitialCapacity(this.initialCapacity);
        }
        vector.allocateNewSafe();
      } 
      writer.setPosition(idx());
      fields.put(handleCase(name), writer);
    } else {
      if (writer instanceof PromotableWriter) {
        // ensure writers are initialized
        ((PromotableWriter)writer).getWriter(MinorType.${upperName});
      }
    }
    return writer;
  }

  </#list></#list>

}
</#list>

```


#### Error stacktrace:

```
scala.meta.internal.mtags.JavaToplevelMtags.unexpectedCharacter(JavaToplevelMtags.scala:352)
	scala.meta.internal.mtags.JavaToplevelMtags.parseToken$1(JavaToplevelMtags.scala:253)
	scala.meta.internal.mtags.JavaToplevelMtags.fetchToken(JavaToplevelMtags.scala:262)
	scala.meta.internal.mtags.JavaToplevelMtags.loop(JavaToplevelMtags.scala:73)
	scala.meta.internal.mtags.JavaToplevelMtags.indexRoot(JavaToplevelMtags.scala:42)
	scala.meta.internal.mtags.MtagsIndexer.index(MtagsIndexer.scala:21)
	scala.meta.internal.mtags.MtagsIndexer.index$(MtagsIndexer.scala:20)
	scala.meta.internal.mtags.JavaToplevelMtags.index(JavaToplevelMtags.scala:18)
	scala.meta.internal.mtags.Mtags.indexWithOverrides(Mtags.scala:74)
	scala.meta.internal.mtags.SymbolIndexBucket.indexSource(SymbolIndexBucket.scala:129)
	scala.meta.internal.mtags.SymbolIndexBucket.addSourceFile(SymbolIndexBucket.scala:108)
	scala.meta.internal.mtags.SymbolIndexBucket.$anonfun$addSourceJar$2(SymbolIndexBucket.scala:74)
	scala.collection.immutable.List.flatMap(List.scala:294)
	scala.meta.internal.mtags.SymbolIndexBucket.$anonfun$addSourceJar$1(SymbolIndexBucket.scala:70)
	scala.meta.internal.io.PlatformFileIO$.withJarFileSystem(PlatformFileIO.scala:77)
	scala.meta.internal.io.FileIO$.withJarFileSystem(FileIO.scala:33)
	scala.meta.internal.mtags.SymbolIndexBucket.addSourceJar(SymbolIndexBucket.scala:68)
	scala.meta.internal.mtags.OnDemandSymbolIndex.$anonfun$addSourceJar$2(OnDemandSymbolIndex.scala:85)
	scala.meta.internal.mtags.OnDemandSymbolIndex.tryRun(OnDemandSymbolIndex.scala:131)
	scala.meta.internal.mtags.OnDemandSymbolIndex.addSourceJar(OnDemandSymbolIndex.scala:84)
	scala.meta.internal.metals.Indexer.indexJar(Indexer.scala:561)
	scala.meta.internal.metals.Indexer.addSourceJarSymbols(Indexer.scala:555)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$5(Indexer.scala:381)
	scala.collection.IterableOnceOps.foreach(IterableOnce.scala:619)
	scala.collection.IterableOnceOps.foreach$(IterableOnce.scala:617)
	scala.collection.AbstractIterable.foreach(Iterable.scala:935)
	scala.collection.IterableOps$WithFilter.foreach(Iterable.scala:905)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$1(Indexer.scala:372)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$1$adapted(Indexer.scala:371)
	scala.collection.IterableOnceOps.foreach(IterableOnce.scala:619)
	scala.collection.IterableOnceOps.foreach$(IterableOnce.scala:617)
	scala.collection.AbstractIterable.foreach(Iterable.scala:935)
	scala.meta.internal.metals.Indexer.indexDependencySources(Indexer.scala:371)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$19(Indexer.scala:192)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.meta.internal.metals.TimerProvider.timedThunk(TimerProvider.scala:25)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$18(Indexer.scala:185)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$18$adapted(Indexer.scala:181)
	scala.collection.immutable.List.foreach(List.scala:334)
	scala.meta.internal.metals.Indexer.indexWorkspace(Indexer.scala:181)
	scala.meta.internal.metals.Indexer.$anonfun$profiledIndexWorkspace$2(Indexer.scala:57)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.meta.internal.metals.TimerProvider.timedThunk(TimerProvider.scala:25)
	scala.meta.internal.metals.Indexer.$anonfun$profiledIndexWorkspace$1(Indexer.scala:57)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.concurrent.Future$.$anonfun$apply$1(Future.scala:687)
	scala.concurrent.impl.Promise$Transformation.run(Promise.scala:467)
	java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	java.base/java.lang.Thread.run(Thread.java:833)
```
#### Short summary: 

Java indexer failed with and exception.